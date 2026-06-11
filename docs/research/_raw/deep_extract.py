"""
深挖 APK 脚本：提取 AndroidManifest 的 intent-filter/deeplink/scheme、
resources/strings.xml 关键文案、assets & lib 目录结构、增强 SDK 检测。
支持 androguard 可用时走完整解析，不可用时走 zipfile 降级。
"""
import sys, json, zipfile, zlib, struct, re, logging, os
from collections import defaultdict

logging.disable(logging.WARNING)
try:
    from loguru import logger as _lg
    _lg.remove()
except Exception:
    pass

HAS_ANDROGUARD = False
try:
    from androguard.core.apk import APK
    HAS_ANDROGUARD = True
except Exception:
    try:
        from androguard.core.bytecodes.apk import APK
        HAS_ANDROGUARD = True
    except Exception:
        pass

try:
    from androguard.core.axml import AXMLPrinter
except Exception:
    AXMLPrinter = None

from xml.etree import ElementTree as ET

NS = "{http://schemas.android.com/apk/res/android}"

# ---------- 增强 SDK 签名 ----------
SDK_SIGNATURES = {
    "AdMob / Google Mobile Ads": b"com/google/android/gms/ads",
    "Google Play Services": b"com/google/android/gms/common",
    "Firebase Analytics": b"com/google/firebase/analytics",
    "Firebase Performance": b"com/google/firebase/perf",
    "Firebase Messaging (FCM)": b"com/google/firebase/messaging",
    "Firebase Crashlytics": b"com/google/firebase/crashlytics",
    "Firebase Remote Config": b"com/google/firebase/remoteconfig",
    "Firebase A/B Testing": b"com/google/firebase/abt",
    "Google Play Billing": b"com/android/billingclient",
    "Google Play In-App Review": b"com/google/android/play/core/review",
    "Google Play In-App Update": b"com/google/android/play/core/appupdate",
    "Facebook SDK": b"com/facebook/appevents",
    "Facebook Login": b"com/facebook/login",
    "Facebook Audience Network": b"com/facebook/ads",
    "AppLovin MAX": b"com/applovin/mediation",
    "AppLovin SDK": b"com/applovin/sdk",
    "ironSource": b"com/ironsource/mediationsdk",
    "Unity Ads": b"com/unity3d/services/ads",
    "Mintegral (Mbridge)": b"com/mbridge/msdk",
    "Vungle": b"com/vungle/warren",
    "Fyber / Inneractive": b"com/fyber/inneractive",
    "Pangle / ByteDance Ads": b"com/bytedance/sdk/openadsdk",
    "AppsFlyer": b"com/appsflyer/AppsFlyerLib",
    "Adjust": b"com/adjust/sdk/Adjust",
    "Branch": b"io/branch/referral",
    "Singular": b"com/singular/sdk",
    "Sensors Analytics": b"com/sensorsdata/analytics",
    "Firebase (general)": b"com/google/firebase",
    "Sentry": b"io/sentry/android",
    "xCrash": b"xcrash/XCrash",
    "OkHttp": b"okhttp3/OkHttpClient",
    "Retrofit": b"retrofit2/Retrofit",
    "Glide": b"com/bumptech/glide",
    "Lottie": b"com/airbnb/lottie",
    "ExoPlayer": b"com/google/android/exoplayer",
    "MMKV": b"com/tencent/mmkv",
    "Google Sign-In": b"com/google/android/gms/auth/api/signin",
    "Twitter SDK": b"com/twitter/sdk/android",
    "Sobot Chat": b"com/sobot/chat",
    "Umeng": b"com/umeng/commonsdk",
    "Bugly": b"com/tencent/bugly",
    "Huawei HMS": b"com/huawei/hms",
    "Huawei Ads": b"com/huawei/openalliance/ad",
    "React Native": b"com/facebook/react",
    "Flutter": b"io/flutter/embedding",
    "Tencent Open SDK": b"com/tencent/connect",
    "Alipay SDK": b"com/alipay/sdk",
    "WeChat Pay": b"com/tencent/mm/opensdk",
    "Xiaomi MiPush": b"com/xiaomi/mipush",
    "Vivo Push": b"com/vivo/push",
    "Meizu Push": b"com/meizu/cloud/pushsdk",
    "OPPO/Heytap Push": b"com/heytap/msp/push",
    "Huawei HMS Push": b"com/huawei/hms/push",
    "Getui Push": b"com/igexin/sdk",
    "AnyThink / TopOn": b"com/anythink/core",
    "Kwai Ads": b"com/kwad/sdk",
    "Sigmob": b"com/sigmob/sdk",
    "Baidu Mobads": b"com/baidu/mobads",
    "GDT / Tencent Ads": b"com/qq/e/ads",
    "Alibaba ACCS/Agoo": b"org/android/agoo",
    "Bytedance APM": b"com/bytedance/apm",
    "Aliyun SLS Log": b"com/aliyun/sls",
    "Easemob IM": b"com/hyphenate/chat",
    "Stripe": b"com/stripe/android",
    "PayPal": b"com/paypal/android",
    "RevenueCat": b"com/revenuecat/purchases",
    "CleverTap": b"com/clevertap/android",
    "OneSignal": b"com/onesignal",
    "Amplitude": b"com/amplitude/api",
    "Mixpanel": b"com/mixpanel/android",
}

KEYWORD_PATTERNS = [
    "sign_in", "check_in", "checkin", "sign in", "daily", "reward",
    "bonus", "coin", "gem", "diamond", "gold", "token",
    "invite", "referral", "share", "friend",
    "coupon", "voucher", "discount", "promo",
    "newcomer", "newbie", "new_user", "beginner", "welcome_gift",
    "streak", "consecutive", "continuous", "reading_time",
    "gift", "present", "lucky", "lottery", "spin", "wheel",
    "review", "comment", "rate", "feedback",
    "fan", "follower", "follow", "like",
    "author", "writer", "create", "publish",
    "refund", "dispute", "cancel_subscription", "restore",
    "subscription", "premium", "vip", "member", "plan",
    "wait", "unlock", "free_chapter", "trial",
    "timer", "countdown", "expire",
    "push", "notification", "remind", "alert",
    "task", "mission", "quest", "achievement",
    "level", "rank", "tier", "badge",
    "welfare", "benefit", "privilege",
    "ad", "rewarded", "interstitial", "banner",
    "event", "campaign", "activity", "promotion",
    "contest", "competition", "challenge",
    "reading_time_reward", "read_minutes",
    "parental", "age_gate", "mature", "adult", "content_rating",
    "gdpr", "ccpa", "privacy", "consent", "data_deletion",
    "ab_test", "experiment", "remote_config", "feature_flag",
]

def attr(el, name):
    return el.get(NS + name) or el.get(name)


def extract_intent_filters(app_el):
    """提取所有 activity/service/receiver 的 intent-filter 细节。"""
    results = []
    for tag in ["activity", "activity-alias", "service", "receiver"]:
        for comp in app_el.findall(tag):
            comp_name = attr(comp, "name") or ""
            for intf in comp.findall("intent-filter"):
                actions = [attr(a, "name") for a in intf.findall("action") if attr(a, "name")]
                categories = [attr(c, "name") for c in intf.findall("category") if attr(c, "name")]
                data_els = intf.findall("data")
                data_items = []
                for d in data_els:
                    item = {}
                    for k in ["scheme", "host", "pathPrefix", "path", "pathPattern", "mimeType", "port"]:
                        v = attr(d, k)
                        if v:
                            item[k] = v
                    if item:
                        data_items.append(item)
                if actions or data_items:
                    results.append({
                        "component": comp_name,
                        "type": tag,
                        "actions": actions,
                        "categories": categories,
                        "data": data_items,
                    })
    return results


def extract_meta_data(app_el):
    """提取 meta-data name + value。"""
    metas = {}
    for m in app_el.findall("meta-data"):
        name = attr(m, "name")
        value = attr(m, "value") or attr(m, "resource") or ""
        if name:
            metas[name] = value
    return metas


def detect_sdks_from_dex(apk_path):
    """扫描 DEX 字节检测 SDK。"""
    hits = []
    try:
        with zipfile.ZipFile(apk_path) as z:
            dex_blobs = []
            for n in z.namelist():
                if n.endswith(".dex"):
                    dex_blobs.append(z.read(n))
            for label, sig in SDK_SIGNATURES.items():
                if any(sig in blob for blob in dex_blobs):
                    hits.append(label)
    except Exception:
        pass
    return sorted(hits)


def detect_sdks_from_dex_stream(data):
    """对加固 APK 用流式解析 DEX。"""
    sig = b"PK\x03\x04"
    hits = []
    dex_blobs = []
    pos, n = 0, len(data)
    while pos + 30 <= n and data[pos:pos+4] == sig:
        try:
            (ver, flags, method, mtime, mdate, crc, comp, uncomp, fnlen, eflen) = struct.unpack(
                "<HHHHHIIIHH", data[pos+4:pos+30])
            name = data[pos+30:pos+30+fnlen].decode("utf-8", "replace")
            header_end = pos + 30 + fnlen + eflen
            if name.endswith(".dex"):
                raw = data[header_end:header_end+comp]
                if method == 8:
                    try:
                        raw = zlib.decompress(raw, -15)
                    except Exception:
                        pass
                dex_blobs.append(raw)
            if (flags & 0x08) and comp == 0:
                break
            pos = header_end + comp
        except Exception:
            break

    for label, sig_bytes in SDK_SIGNATURES.items():
        if any(sig_bytes in blob for blob in dex_blobs):
            hits.append(label)
    return sorted(hits)


def extract_strings_from_arsc(apk_obj, locale=""):
    """从 resources.arsc 提取指定 locale 的 string 资源。"""
    strings = {}
    try:
        arsc = apk_obj.get_android_resources()
        for pkg in arsc.get_packages_names():
            try:
                for t in arsc.get_types(pkg):
                    pass
            except Exception:
                pass
            try:
                str_type = arsc.get_string_resources(pkg, locale)
                if str_type:
                    for k, v in str_type.items():
                        strings[k] = v
            except Exception:
                pass
            try:
                configs = arsc.get_resolved_strings()
                if configs:
                    for p, types in configs.items():
                        if "string" in types:
                            for loc, kvs in types["string"].items():
                                if (not locale and not loc) or loc == locale:
                                    for k, v in kvs.items():
                                        strings[k] = v
            except Exception:
                pass
    except Exception:
        pass
    return strings


def filter_functional_strings(strings_dict):
    """过滤出功能性文案。"""
    functional = {}
    patterns_lower = [p.lower() for p in KEYWORD_PATTERNS]
    for key, value in strings_dict.items():
        key_lower = (key or "").lower()
        value_lower = (str(value) or "").lower()
        for pat in patterns_lower:
            if pat in key_lower or pat in value_lower:
                functional[key] = str(value)
                break
    return functional


def list_assets_and_libs(apk_path):
    """列出 assets/ 和 lib/ 目录结构。"""
    assets = []
    libs = []
    try:
        with zipfile.ZipFile(apk_path) as z:
            for n in z.namelist():
                if n.startswith("assets/") and not n.endswith("/"):
                    assets.append(n)
                elif n.startswith("lib/") and not n.endswith("/"):
                    libs.append(n)
    except Exception:
        pass
    return sorted(assets), sorted(libs)


def list_assets_and_libs_stream(data):
    """流式列出 assets/ 和 lib/。"""
    sig_bytes = b"PK\x03\x04"
    assets = []
    libs = []
    pos, n = 0, len(data)
    while pos + 30 <= n and data[pos:pos+4] == sig_bytes:
        try:
            (ver, flags, method, mtime, mdate, crc, comp, uncomp, fnlen, eflen) = struct.unpack(
                "<HHHHHIIIHH", data[pos+4:pos+30])
            name = data[pos+30:pos+30+fnlen].decode("utf-8", "replace")
            header_end = pos + 30 + fnlen + eflen
            if name.startswith("assets/") and not name.endswith("/"):
                assets.append(name)
            elif name.startswith("lib/") and not name.endswith("/"):
                libs.append(name)
            if (flags & 0x08) and comp == 0:
                break
            pos = header_end + comp
        except Exception:
            break
    return sorted(assets), sorted(libs)


def categorize_assets(asset_list):
    """分类 assets。"""
    categories = defaultdict(list)
    for a in asset_list:
        ext = os.path.splitext(a)[1].lower()
        if ext in [".ttf", ".otf", ".woff", ".woff2"]:
            categories["fonts"].append(a)
        elif ext in [".json", ".cfg", ".xml", ".txt", ".properties"]:
            categories["config_data"].append(a)
        elif ext in [".html", ".css", ".js"]:
            categories["h5_web"].append(a)
        elif ext in [".apk", ".jar", ".dex"]:
            categories["plugins_jars"].append(a)
        elif ext in [".png", ".jpg", ".jpeg", ".webp", ".gif", ".svg", ".svga"]:
            categories["images_anim"].append(a)
        elif ext in [".mp3", ".mp4", ".wav", ".ogg"]:
            categories["media"].append(a)
        elif ext in [".so"]:
            categories["native_libs_in_assets"].append(a)
        elif ext in [".skin", ".czl"]:
            categories["themes_skins"].append(a)
        elif ext in [".pem", ".bks", ".cert"]:
            categories["certificates"].append(a)
        else:
            categories["other"].append(a)
    return dict(categories)


def process_goodnovel(apk_path):
    """GoodNovel：未加固，androguard 完整解析。"""
    result = {"source": apk_path}

    if HAS_ANDROGUARD:
        a = APK(apk_path)

        root = None
        try:
            raw_manifest = a.get_file("AndroidManifest.xml")
            if AXMLPrinter:
                root = ET.fromstring(AXMLPrinter(raw_manifest).get_xml())
        except Exception:
            pass
        if root is None:
            try:
                lxml_root = a.get_android_manifest_xml()
                from lxml import etree as lxml_etree
                xml_bytes = lxml_etree.tostring(lxml_root)
                root = ET.fromstring(xml_bytes)
            except Exception:
                pass

        if root is not None:
            app = root.find("application")
            if app is not None:
                result["intent_filters"] = extract_intent_filters(app)
                result["meta_data_full"] = extract_meta_data(app)

        all_strings = extract_strings_from_arsc(a, "")
        en_strings = extract_strings_from_arsc(a, "en")
        combined = {**all_strings, **en_strings}
        result["string_count"] = len(combined)
        result["functional_strings"] = filter_functional_strings(combined)
    else:
        result["note"] = "androguard unavailable, limited extraction"

    result["sdks"] = detect_sdks_from_dex(apk_path)
    assets, libs = list_assets_and_libs(apk_path)
    result["assets_list"] = assets
    result["assets_categories"] = categorize_assets(assets)
    result["libs_list"] = libs
    return result


def process_ireader(apk_path):
    """iReader：加固，用流式解析。"""
    with open(apk_path, "rb") as f:
        data = f.read()

    result = {"source": apk_path, "size": len(data)}

    manifest_raw = None
    sig = b"PK\x03\x04"
    pos, n = 0, len(data)
    while pos + 30 <= n and data[pos:pos+4] == sig:
        try:
            (ver, flags, method, mtime, mdate, crc, comp, uncomp, fnlen, eflen) = struct.unpack(
                "<HHHHHIIIHH", data[pos+4:pos+30])
            name = data[pos+30:pos+30+fnlen].decode("utf-8", "replace")
            header_end = pos + 30 + fnlen + eflen
            if name == "AndroidManifest.xml":
                raw = data[header_end:header_end+comp]
                if method == 8:
                    try:
                        manifest_raw = zlib.decompress(raw, -15)
                    except Exception:
                        manifest_raw = raw
                else:
                    manifest_raw = raw
                break
            if (flags & 0x08) and comp == 0:
                break
            pos = header_end + comp
        except Exception:
            break

    if manifest_raw and AXMLPrinter:
        try:
            xml_bytes = AXMLPrinter(manifest_raw).get_xml()
            root = ET.fromstring(xml_bytes)
            app = root.find("application")
            if app is not None:
                result["intent_filters"] = extract_intent_filters(app)
                result["meta_data_full"] = extract_meta_data(app)
        except Exception as e:
            result["manifest_parse_error"] = str(e)

    result["sdks"] = detect_sdks_from_dex_stream(data)
    assets, libs = list_assets_and_libs_stream(data)
    result["assets_list"] = assets
    result["assets_categories"] = categorize_assets(assets)
    result["libs_list"] = libs
    result["note"] = "加固 APK，流式解析；strings.xml 不可从 arsc 提取"
    return result


def main():
    base = os.path.dirname(os.path.abspath(__file__))
    apk_dir = os.path.join(os.path.dirname(base), "竞品apk")

    gn_apk = os.path.join(apk_dir, "GoodNovel_v2.5.8.1168.apk")
    ir_apk = os.path.join(apk_dir, "iReader_international_v8.7.3.1.apk")

    print("=== Processing GoodNovel ===")
    gn_result = process_goodnovel(gn_apk)
    gn_out = os.path.join(base, "goodnovel_deep.json")
    with open(gn_out, "w", encoding="utf-8") as f:
        json.dump(gn_result, f, ensure_ascii=False, indent=2, default=str)
    print(f"WROTE {gn_out}")
    print(f"  SDKs: {len(gn_result.get('sdks', []))}")
    print(f"  Intent Filters: {len(gn_result.get('intent_filters', []))}")
    print(f"  Functional Strings: {len(gn_result.get('functional_strings', {}))}")
    print(f"  Assets: {len(gn_result.get('assets_list', []))}")

    print("\n=== Processing iReader ===")
    ir_result = process_ireader(ir_apk)
    ir_out = os.path.join(base, "ireader_deep.json")
    with open(ir_out, "w", encoding="utf-8") as f:
        json.dump(ir_result, f, ensure_ascii=False, indent=2, default=str)
    print(f"WROTE {ir_out}")
    print(f"  SDKs: {len(ir_result.get('sdks', []))}")
    print(f"  Intent Filters: {len(ir_result.get('intent_filters', []))}")
    print(f"  Assets: {len(ir_result.get('assets_list', []))}")


if __name__ == "__main__":
    main()
