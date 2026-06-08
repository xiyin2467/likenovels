import sys, struct, json, zlib

# 流式扫描本地文件头(PK\x03\x04)，绕过缺失/加密的中央目录。
# 输出文件名清单 + 尝试解出 AndroidManifest.xml 的原始字节。

def scan(path):
    with open(path, "rb") as f:
        data = f.read()
    n = len(data)
    sig = b"PK\x03\x04"
    names = []
    manifest_bytes = None
    i = 0
    # 先用顺序解析：从0开始按本地头结构走；若中途崩，退化为全局搜索签名。
    seq_names = []
    pos = 0
    try:
        while pos + 30 <= n and data[pos:pos+4] == sig:
            (ver, flags, method, mtime, mdate, crc, comp, uncomp, fnlen, eflen) = struct.unpack(
                "<HHHHHIIIHH", data[pos+4:pos+30])
            name = data[pos+30:pos+30+fnlen].decode("utf-8", "replace")
            header_end = pos + 30 + fnlen + eflen
            seq_names.append((name, method, comp, uncomp))
            if name == "AndroidManifest.xml":
                raw = data[header_end:header_end+comp]
                if method == 8:
                    try:
                        manifest_bytes = zlib.decompress(raw, -15)
                    except Exception:
                        manifest_bytes = raw
                else:
                    manifest_bytes = raw
            # data descriptor (flag bit 3) 时 comp 可能为0，无法顺序前进
            if (flags & 0x08) and comp == 0:
                break
            pos = header_end + comp
    except Exception as e:
        seq_names.append(("_SEQ_ERROR_:" + str(e), 0, 0, 0))

    # 全局搜索所有本地头签名（即使顺序解析中断也能拿到全部文件名）
    all_names = []
    start = 0
    while True:
        idx = data.find(sig, start)
        if idx == -1:
            break
        if idx + 30 <= n:
            try:
                fnlen = struct.unpack("<H", data[idx+26:idx+28])[0]
                eflen = struct.unpack("<H", data[idx+28:idx+30])[0]
                method = struct.unpack("<H", data[idx+8:idx+10])[0]
                comp = struct.unpack("<I", data[idx+18:idx+22])[0]
                name = data[idx+30:idx+30+fnlen].decode("utf-8", "replace")
                if 0 < fnlen < 512 and all(ord(c) >= 9 for c in name):
                    all_names.append({"name": name, "method": method, "comp": comp, "off": idx})
            except Exception:
                pass
        start = idx + 4

    result = {
        "source": path,
        "size": n,
        "seq_parsed_count": len(seq_names),
        "local_header_hits": len(all_names),
        "names": [x["name"] for x in all_names],
        "names_detail_head": all_names[:60],
        "has_manifest_decoded": manifest_bytes is not None,
    }
    if manifest_bytes:
        with open(path + ".manifest.bin", "wb") as mf:
            mf.write(manifest_bytes)
        result["manifest_bin"] = path + ".manifest.bin"
        result["manifest_len"] = len(manifest_bytes)
    return result


if __name__ == "__main__":
    res = scan(sys.argv[1])
    out = sys.argv[2]
    with open(out, "w", encoding="utf-8") as f:
        json.dump(res, f, ensure_ascii=False, indent=2)
    print("WROTE", out)
    print("size:", res["size"], "local_header_hits:", res["local_header_hits"],
          "seq_parsed:", res["seq_parsed_count"], "manifest:", res["has_manifest_decoded"])
    print("first names:", res["names"][:20])
