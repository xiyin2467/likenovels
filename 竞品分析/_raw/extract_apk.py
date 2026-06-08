import sys, json, zipfile, logging

logging.disable(logging.WARNING)
try:
    from loguru import logger as _lg
    _lg.remove()
except Exception:
    pass

try:
    from androguard.core.apk import APK
except Exception:
    from androguard.core.bytecodes.apk import APK  # 旧版本兜底

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
    "Tencent Open": b"com/tencent/connect",
    "Sentry": b"io/sentry",
    "OkHttp": b"okhttp3",
    "Retrofit": b"retrofit2",
    "Glide": b"com/bumptech/glide",
    "Stripe": b"com/stripe/android",
    "PayPal": b"com/paypal",
    "React Native": b"com/facebook/react",
    "Flutter": b"io/flutter",
    "Lottie": b"com/airbnb/lottie",
    "ExoPlayer": b"com/google/android/exoplayer",
    "WebView/Chromium": b"org/chromium",
    "Sensors Analytics": b"com/sensorsdata",
    "Umeng": b"com/umeng",
    "TalkingData": b"com/tendcloud",
    "Singular": b"com/singular/sdk",
}


def detect_sdks(apk_path):
    hits = []
    try:
        with zipfile.ZipFile(apk_path) as z:
            dex_blobs = [z.read(n) for n in z.namelist() if n.endswith(".dex")]
            native_libs = sorted(set(
                n.split("/")[-1] for n in z.namelist() if n.startswith("lib/") and n.endswith(".so")
            ))
            abis = sorted(set(
                n.split("/")[1] for n in z.namelist() if n.startswith("lib/") and len(n.split("/")) > 2
            ))
            for label, sig in SDK_SIGNATURES.items():
                if any(sig in blob for blob in dex_blobs):
                    hits.append(label)
        return sorted(hits), native_libs, abis
    except Exception as e:
        return [{"_error": str(e)}], [], []


def safe(fn, default=None):
    try:
        return fn()
    except Exception as e:
        return {"_error": str(e)} if default is None else default


def main(apk_path, out_path):
    a = APK(apk_path)
    data = {}
    data["source_apk"] = apk_path
    data["package"] = safe(a.get_package, "")
    data["version_code"] = safe(a.get_androidversion_code, "")
    data["version_name"] = safe(a.get_androidversion_name, "")
    data["app_name"] = safe(a.get_app_name, "")
    data["min_sdk"] = safe(a.get_min_sdk_version, "")
    data["target_sdk"] = safe(a.get_target_sdk_version, "")
    data["max_sdk"] = safe(a.get_max_sdk_version, "")
    data["main_activity"] = safe(a.get_main_activity, "")
    data["permissions"] = safe(lambda: sorted(a.get_permissions()), [])
    data["activities"] = safe(lambda: sorted(a.get_activities()), [])
    data["services"] = safe(lambda: sorted(a.get_services()), [])
    data["receivers"] = safe(lambda: sorted(a.get_receivers()), [])
    data["providers"] = safe(lambda: sorted(a.get_providers()), [])
    data["features"] = safe(lambda: sorted(a.get_features()), [])
    data["libraries"] = safe(lambda: sorted(a.get_libraries()), [])
    data["meta_data"] = safe(lambda: a.get_elements("meta-data", "name"), [])

    def locales():
        arsc = a.get_android_resources()
        locs = set()
        for pkg in arsc.get_packages_names():
            try:
                for loc in arsc.get_locales(pkg):
                    if loc:
                        locs.add(loc)
            except Exception:
                pass
        return sorted(locs)
    data["locales"] = safe(locales, [])

    def certs():
        out = []
        for c in a.get_certificates():
            out.append({"subject": str(c.subject), "issuer": str(c.issuer)})
        return out
    data["certificates"] = safe(certs, [])

    sdks, native_libs, abis = detect_sdks(apk_path)
    data["sdks"] = sdks
    data["native_libs"] = native_libs
    data["abis"] = abis

    data["counts"] = {
        "activities": len(data["activities"]) if isinstance(data["activities"], list) else 0,
        "services": len(data["services"]) if isinstance(data["services"], list) else 0,
        "receivers": len(data["receivers"]) if isinstance(data["receivers"], list) else 0,
        "providers": len(data["providers"]) if isinstance(data["providers"], list) else 0,
        "permissions": len(data["permissions"]) if isinstance(data["permissions"], list) else 0,
    }

    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print("WROTE", out_path)
    print("package:", data["package"], "version:", data["version_name"])
    print("counts:", data["counts"])
    print("sdks:", data["sdks"])


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
