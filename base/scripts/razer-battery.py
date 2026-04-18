#!/usr/bin/env python3
"""Query Razer mouse battery level over HID feature reports.

Works without openrazer / kernel modules. Defaults to the Viper V3 Pro
(USB 1532:00c1) but accepts --vid/--pid to target other Razer devices.
Prints the battery percentage (integer) on stdout on success; silent on
failure so it's safe to wire into waybar's "exec".
"""

import argparse
import fcntl
import glob
import os
import sys
import time

REPORT_LEN = 91  # 1 byte report-ID + 90 byte Razer report


def _ioc(direction: int, type_: int, nr: int, size: int) -> int:
    return (direction << 30) | (size << 16) | (type_ << 8) | nr


def _hidiocsfeature(size: int) -> int:
    return _ioc(3, ord("H"), 6, size)


def _hidiocgfeature(size: int) -> int:
    return _ioc(3, ord("H"), 7, size)


def _razer_crc(report: bytes) -> int:
    crc = 0
    for b in report[2:88]:
        crc ^= b
    return crc


def _build_report(transaction_id: int, cmd_class: int, cmd_id: int,
                  data_size: int = 2, args: bytes = b"") -> bytes:
    buf = bytearray(90)
    buf[1] = transaction_id
    buf[5] = data_size
    buf[6] = cmd_class
    buf[7] = cmd_id
    for i, a in enumerate(args):
        buf[8 + i] = a
    buf[88] = _razer_crc(bytes(buf))
    return bytes(buf)


def _find_hidraws(vid: int, pid: int) -> list[str]:
    out = []
    for path in sorted(glob.glob("/sys/class/hidraw/hidraw*")):
        uevent = os.path.join(path, "device/uevent")
        try:
            with open(uevent) as f:
                text = f.read()
        except OSError:
            continue
        hid_id = next((l.split("=", 1)[1] for l in text.splitlines()
                       if l.startswith("HID_ID=")), None)
        if not hid_id:
            continue
        parts = hid_id.split(":")
        if len(parts) != 3:
            continue
        try:
            v = int(parts[1], 16)
            p = int(parts[2], 16)
        except ValueError:
            continue
        if v == vid and p == pid:
            out.append("/dev/" + os.path.basename(path))
    return out


def _query(path: str, transaction_id: int) -> int | None:
    tx = bytes([0x00]) + _build_report(transaction_id, 0x07, 0x80)
    tx_buf = bytearray(tx)
    fd = os.open(path, os.O_RDWR)
    try:
        fcntl.ioctl(fd, _hidiocsfeature(REPORT_LEN), tx_buf, True)
        time.sleep(0.05)
        rx_buf = bytearray(REPORT_LEN)
        fcntl.ioctl(fd, _hidiocgfeature(REPORT_LEN), rx_buf, True)
    finally:
        os.close(fd)

    report = rx_buf[1:]  # strip report-ID
    status = report[0]
    # 0x02 = command successful; anything else means the command wasn't
    # understood on this interface / with this transaction id.
    if status != 0x02:
        return None
    level = report[9]  # arguments[1]
    return round(level / 255 * 100)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--vid", type=lambda s: int(s, 16), default=0x1532)
    ap.add_argument("--pid", type=lambda s: int(s, 16), default=0x00C1)
    args = ap.parse_args()

    devs = _find_hidraws(args.vid, args.pid)
    if not devs:
        return 0

    # Transaction IDs vary by model; 0x1f covers most modern wireless mice,
    # 0x3f covers older ones. Try both across all matching interfaces.
    for tid in (0x1F, 0x3F):
        for dev in devs:
            try:
                pct = _query(dev, tid)
            except OSError:
                continue
            if pct is not None and 0 < pct <= 100:
                print(pct)
                return 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
