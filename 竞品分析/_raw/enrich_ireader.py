import sys, struct, json, zlib, logging

logging.disable(logging.WARNING)
try:
    from loguru import logger as _lg
    _lg.remove()
except Exception:
    pass

from androguard.core.axml import AXMLPrinter
from xml.etree import ElementTree as ET

SDK_SIGNATURES = {
    "AdMob / Google Mobile Ads": b"com/google/android/gms/ads",
    "Google Play Services": b"com/google/android/gms/common",
    "Firebase": b"com/google/firebase",
    "Google Play Billing": b"com/android/billingclient",
    "Facebook SDK": b"com/facebook",
    "AppLovin": b"com/applovin",
    "ironSource": b"com/ironsource",
    "Unity Ads": b"com/unity3d/ads",
    "Pangle / ByteDance": b"com/bytedance/sdk",
    "AppsFlyer": b"com/appsflyer",
    "Adjust": b"com/adjust/sdk",
    "Branch": b"io/branch",
    "Bugly": b"com/tencent/bugly",
    "Sentry": b"io/sentry",
    "OkHttp": b"okhttp3",
    "Retrofit": b"retrofit2",
    "Glide": b"com/bumptech/glide",
    "Stripe": b"com/stripe/android",
    "PayPal": b"com/paypal",
    "Huawei HMS": b"com/huawei/hms",
    "Huawei Ads": b"com/huawei/openalliance",
    "ExoPlayer": b"com/google/android/exoplayer",
    "Lottie": b"com/airbnb/lottie",
    "React Native": b"com/facebook/react",
    "Flutter": b"io/flutter",
    "Sensors Analytics": b"com/sensorsdata",
    "Umeng": b"com/umeng",
    "Singular": b"com/singular/sdk",
    "Tencent Open": b"com/tencent/connect",
}

NS_ANDROID = "{http://schemas.android.com/apk/res/android}"


def iter_entries(data):
    sig = b"PK\x03\x04"
    pos, n = 0, len(data)
    entries = []
    while pos + 30 <= n and data[pos:pos+4] == sig:
        (ver, flags, method, mtime, mdate, crc, comp, uncomp, fnlen, eflen) = struct.unpack(
            "<HHHHHIIIHH", data[pos+4:pos+30])
        name = data[pos+30:pos+30+fnlen].decode("utf-8", "replace")
        header_end = pos + 30 + fnlen + eflen
        entries.append((name, method, comp, uncomp, header_end))
        if (flags & 0x08) and comp == 0:
            break
        pos = header_end + comp
    return entries


def read_entry(data, method, comp, header_end):
    raw = data[header_end:header_end+comp]
    if method == 8:
        try:
            return zlib.decompress(raw, -15)
        except Exception:
            return raw
    return raw


def attr(el, name):
    return el.get(NS_ANDROID + name) or el.get(name)


def main(apk_path, out_path):
    with open(apk_path, "rb") as f:
        data = f.read()
    entries = iter_entries(data)

    result = {"source_apk": apk_path, "size": len(data), "entry_count": len(entries)}

    # --- AndroidManifest.xml ---
    manifest_raw = None
    for (name, method, comp, uncomp, he) in entries:
        if name == "AndroidManifest.xml":
            manifest_raw = read_entry(data, method, comp, he)
            break
    if manifest_raw:
        xml_bytes = AXMLPrinter(manifest_raw).get_xml()
        root = ET.fromstring(xml_bytes)
        result["package"] = root.get("package", "")
        result["version_code"] = root.get(NS_ANDROID + "versionCode", "")
        result["version_name"] = root.get(NS_ANDROID + "versionName", "")
        usdk = root.find("uses-sdk")
        if usdk is not None:
            result["min_sdk"] = attr(usdk, "minSdkVersion")
            result["target_sdk"] = attr(usdk, "targetSdkVersion")
        perms = sorted({attr(p, "name") for p in root.findall("uses-permission") if attr(p, "name")})
        result["permissions"] = perms
        feats = sorted({attr(p, "name") for p in root.findall("uses-feature") if attr(p, "name")})
        result["features"] = feats
        app = root.find("application")
        acts, svcs, recs, provs = [], [], [], []
        main_activity = ""
        if app is not None:
            for a in app.findall("activity") + app.findall("activity-alias"):
                nm = attr(a, "name")
                if nm:
                    acts.append(nm)
                    for intent in a.findall("intent-filter"):
                        for act in intent.findall("action"):
                            if attr(act, "name") == "android.intent.action.MAIN":
                                main_activity = nm
            for s in app.findall("service"):
                if attr(s, "name"):
                    svcs.append(attr(s, "name"))
            for r in app.findall("receiver"):
                if attr(r, "name"):
                    recs.append(attr(r, "name"))
            for p in app.findall("provider"):
                if attr(p, "name"):
                    provs.append(attr(p, "name"))
            metas = sorted({attr(m, "name") for m in app.findall("meta-data") if attr(m, "name")})
            result["meta_data"] = metas
        result["activities"] = sorted(set(acts))
        result["services"] = sorted(set(svcs))
        result["receivers"] = sorted(set(recs))
        result["providers"] = sorted(set(provs))
        result["main_activity"] = main_activity

    # --- DEX 签名检测 ---
    dex_blobs = []
    for (name, method, comp, uncomp, he) in entries:
        if name.endswith(".dex"):
            dex_blobs.append(read_entry(data, method, comp, he))
    sdks = []
    for label, sig in SDK_SIGNATURES.items():
        if any(sig in blob for blob in dex_blobs):
            sdks.append(label)
    result["sdks"] = sorted(sdks)
    result["dex_count"] = len(dex_blobs)

    # --- 依赖库版本(META-INF/*.version) + native libs + abis ---
    lib_versions = {}
    native_libs = set()
    abis = set()
    hms_props = []
    for (name, method, comp, uncomp, he) in entries:
        if name.startswith("META-INF/") and name.endswith(".version"):
            content = read_entry(data, method, comp, he).decode("utf-8", "replace").strip()
            lib = name[len("META-INF/"):-len(".version")]
            lib_versions[lib] = content
        elif name.startswith("lib/") and name.endswith(".so"):
            parts = name.split("/")
            if len(parts) >= 3:
                abis.add(parts[1])
                native_libs.add(parts[-1])
        elif name.startswith("HMSCore-") and name.endswith(".properties"):
            hms_props.append(name)
    result["lib_versions"] = dict(sorted(lib_versions.items()))
    result["native_libs"] = sorted(native_libs)
    result["abis"] = sorted(abis)
    result["hms_properties"] = sorted(hms_props)

    result["counts"] = {
        "activities": len(result.get("activities", [])),
        "services": len(result.get("services", [])),
        "receivers": len(result.get("receivers", [])),
        "providers": len(result.get("providers", [])),
        "permissions": len(result.get("permissions", [])),
        "lib_versions": len(lib_versions),
    }
    result["note"] = "中央目录缺失/加密；本数据由流式解析本地文件头+AXML清单解析得到。"

    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
    print("WROTE", out_path)
    print("package:", result.get("package"), "version:", result.get("version_name"))
    print("counts:", result["counts"])
    print("sdks:", result["sdks"])
    print("lib_versions:", result["counts"]["lib_versions"], "abis:", result["abis"])


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
