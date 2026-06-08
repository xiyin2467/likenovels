# 竞品分析 + 产品规划 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 对 GoodNovel 与 iReader 国际版两款竞品 APK 做产品+技术静态拆解，并据此产出一套中文产品规划文档。

**Architecture:** 用一个 Python 脚本（androguard）把两个 APK 的结构化事实提取成 JSON（存入 `竞品分析/_raw/`），再由人/agent 据此撰写中文 Markdown 分析文档；阶段 1（分析）完成后设检查点，阶段 2 写规划文档。

**Tech Stack:** Python 3 + androguard（已安装），Markdown 文档，Windows / PowerShell 环境。

---

## File Structure

- Create: `竞品分析/_raw/extract_apk.py` — androguard 提取脚本（唯一职责：APK → 结构化 JSON）。
- Create: `竞品分析/_raw/goodnovel.json`、`竞品分析/_raw/ireader.json` — 提取出的原始事实。
- Create: `竞品分析/GoodNovel/技术拆解.md`、`竞品分析/GoodNovel/产品分析.md`
- Create: `竞品分析/iReader国际版/技术拆解.md`、`竞品分析/iReader国际版/产品分析.md`
- Create: `竞品分析/竞品横向对比.md`
- Create（阶段 2）: `项目规划/市场与定位建议.md`、`项目规划/产品功能规划.md`、`项目规划/MVP范围与路线图.md`、`项目规划/变现模型.md`、`项目规划/技术选型建议.md`
- Create（阶段 2）: `项目文档/README.md`

---

## 阶段 1：竞品技术 + 产品拆解

### Task 1: 编写 APK 提取脚本

**Files:**
- Create: `竞品分析/_raw/extract_apk.py`

- [ ] **Step 1: 写提取脚本**

脚本读取一个 APK，输出结构化 JSON（基本信息、权限、四大组件、SDK 命中、语言、证书、文件清单摘要）。对 androguard 不同版本做导入兜底，每个区块 try/except 保证部分失败不影响整体。

```python
import sys, json, re, zipfile

try:
    from androguard.core.apk import APK
except Exception:
    from androguard.core.bytecodes.apk import APK  # 旧版本兜底

# 已知第三方 SDK 的 DEX 包前缀签名（命中即认为集成）
SDK_SIGNATURES = {
    "AdMob / Google Mobile Ads": b"com/google/android/gms/ads",
    "Google Play Services": b"com/google/android/gms/common",
    "Firebase": b"com/google/firebase",
    "Google Play Billing": b"com/android/billingclient",
    "Facebook SDK": b"com/facebook",
    "AppLovin": b"com/applovin",
    "ironSource": b"com/ironsource",
    "Unity Ads": b"com/unity3d/ads",
    "Pangle / TopOn": b"com/bytedance/sdk",
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
}

def detect_sdks(apk_path):
    hits = []
    with zipfile.ZipFile(apk_path) as z:
        dex_blobs = []
        for name in z.namelist():
            if name.endswith(".dex"):
                dex_blobs.append(z.read(name))
        for label, sig in SDK_SIGNATURES.items():
            if any(sig in blob for blob in dex_blobs):
                hits.append(label)
    return sorted(hits)

def safe(fn, default=None):
    try:
        return fn()
    except Exception as e:
        return {"_error": str(e)} if default is None else default

def main(apk_path, out_path):
    a = APK(apk_path)
    data = {}
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
    # 语言/地区
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
    # 证书主体
    def certs():
        out = []
        for c in a.get_certificates():
            out.append({"subject": str(c.subject), "issuer": str(c.issuer)})
        return out
    data["certificates"] = safe(certs, [])
    data["sdks"] = detect_sdks(apk_path)
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print("WROTE", out_path)
    print("keys:", list(data.keys()))

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
```

- [ ] **Step 2: 提交（如已初始化 git）**

当前目录非 git 仓库；若已初始化则 `git add 竞品分析/_raw/extract_apk.py && git commit -m "feat: APK 提取脚本"`，否则跳过。

### Task 2: 提取 GoodNovel 数据

**Files:**
- Create: `竞品分析/_raw/goodnovel.json`

- [ ] **Step 1: 运行提取脚本**

Run（在 `d:\likenovels`）:
```
python 竞品分析/_raw/extract_apk.py "竞品分析/竞品apk/GoodNovel_v2.5.8.1168.apk" 竞品分析/_raw/goodnovel.json
```
Expected: 打印 `WROTE 竞品分析/_raw/goodnovel.json` 与 keys 列表。

- [ ] **Step 2: 校验输出**

读 `竞品分析/_raw/goodnovel.json`，确认 `package`、`permissions`、`activities`、`sdks` 非空且无大面积 `_error`。若某区块报错，记录在该 APK 文档的「数据缺口」小节，继续后续步骤（不阻塞）。

### Task 3: 提取 iReader 数据

**Files:**
- Create: `竞品分析/_raw/ireader.json`

- [ ] **Step 1: 运行提取脚本**

Run:
```
python 竞品分析/_raw/extract_apk.py "竞品分析/竞品apk/iReader_international_v8.7.3.1.apk" 竞品分析/_raw/ireader.json
```
Expected: 打印 `WROTE 竞品分析/_raw/ireader.json`。

- [ ] **Step 2: 校验输出** — 同 Task 2 的校验标准。

### Task 4: 撰写 GoodNovel 技术拆解 + 产品分析

**Files:**
- Create: `竞品分析/GoodNovel/技术拆解.md`
- Create: `竞品分析/GoodNovel/产品分析.md`

- [ ] **Step 1: 写技术拆解.md**

依据 `goodnovel.json` 填充：基本信息表（包名/版本/SDK 等）、权限分类表、四大组件统计与代表性页面、命中的第三方 SDK 及其用途解读、支持语言列表、证书主体、数据缺口。事实部分注明来源 JSON，推断部分标「推断」。

- [ ] **Step 2: 写产品分析.md**

功能地图、核心用户流程（登录→发现→阅读→付费）、变现模式、增长玩法、UX 亮点/短板。明确区分「APK 事实」与「产品认知推断」。

- [ ] **Step 3: 提交（如适用）**

### Task 5: 撰写 iReader 技术拆解 + 产品分析

**Files:**
- Create: `竞品分析/iReader国际版/技术拆解.md`
- Create: `竞品分析/iReader国际版/产品分析.md`

- [ ] **Step 1-3:** 同 Task 4 的三步，数据源改为 `ireader.json`，目录改为 `iReader国际版/`。

### Task 6: 撰写竞品横向对比

**Files:**
- Create: `竞品分析/竞品横向对比.md`

- [ ] **Step 1: 写对比文档**

横向对比表（维度：定位/内容/变现/SDK 生态/技术指标/UX），逐维度给结论，末尾给「对我们做自己 App 的启示」要点列表。

- [ ] **Step 2: 提交（如适用）**

### ⛳ 检查点（阶段 1 结束）

暂停，请用户复核 `竞品分析/` 全部内容，确认结论无误后再进入阶段 2。

---

## 阶段 2：产品规划

### Task 7: 市场与定位建议

**Files:**
- Create: `项目规划/市场与定位建议.md`

- [ ] **Step 1:** 基于竞品对比，给出目标市场建议（欧美英语 / 东南亚 / 多区域多语言）、目标人群画像、差异化定位与理由。

### Task 8: 产品功能规划

**Files:**
- Create: `项目规划/产品功能规划.md`

- [ ] **Step 1:** 功能清单按模块（账号/书库/发现/阅读器/付费/增长）罗列，每项标 MoSCoW（Must/Should/Could/Won't）与对标竞品来源。

### Task 9: MVP 范围与路线图

**Files:**
- Create: `项目规划/MVP范围与路线图.md`

- [ ] **Step 1:** 定义 MVP（取 Task 8 的 Must 项），给出 V1/V2/V3 迭代路线与里程碑。

### Task 10: 变现模型

**Files:**
- Create: `项目规划/变现模型.md`

- [ ] **Step 1:** 设计金币/订阅/章节解锁/广告的组合，定价区间、解锁节奏、广告位策略，参考竞品做法。

### Task 11: 技术选型建议

**Files:**
- Create: `项目规划/技术选型建议.md`

- [ ] **Step 1:** 客户端（原生/跨平台）、后端、内容管理、本地化、支付与广告 SDK 选型建议及理由。

### Task 12: 项目总览 README

**Files:**
- Create: `项目文档/README.md`

- [ ] **Step 1:** 写总览索引，串联竞品分析与规划全部文档，附阅读顺序与当前进度。

---

## Self-Review

**Spec coverage：**
- 技术拆解维度 → Task 1/4/5 覆盖（清单/权限/组件/SDK/语言/证书）。
- 产品分析维度 → Task 4/5 覆盖。
- 横向对比 → Task 6。
- 市场建议/功能 MoSCoW/MVP/变现/技术选型 → Task 7–11。
- README 索引 → Task 12。
- 检查点（方案 A 分阶段）→ Task 6 后的检查点。
- 原始数据可溯源 → Task 2/3 的 `_raw/*.json`。

**Placeholder scan：** 脚本代码完整给出；文档任务描述了具体填充内容，无 TBD/TODO。

**Type consistency：** JSON 字段名（package/permissions/activities/services/receivers/providers/locales/certificates/sdks）在 Task 1 定义，Task 4/5 引用一致。

**备注：** 当前非 git 仓库，所有「提交」步骤在未初始化 git 时跳过。
