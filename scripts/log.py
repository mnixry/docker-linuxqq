"""
Act as a Supervisord event listener and send the logs to the console
"""

from datetime import datetime
import os
import sys
from typing import Dict


def write_stdout(s: str):
    sys.stdout.write(s)
    sys.stdout.flush()


def write_stderr(s: str):
    sys.stderr.write(s)
    sys.stderr.flush()


def parse_payload(line: str) -> Dict[str, str]:
    sections = [section.strip() for section in line.split()]
    return {k: v for k, v in [section.split(":", 1) for section in sections]}


def receive_input():
    header = parse_payload(sys.stdin.readline())
    payload = sys.stdin.read(int(header["len"]))

    header_str, *data = payload.split("\n")
    event = parse_payload(header_str)
    payload = "\n".join(data)

    return header, event, payload


LOG_HEADER_COLOR = [
    "\033[31m",  # red
    "\033[32m",  # green
    "\033[33m",  # yellow
    "\033[34m",  # blue
    "\033[35m",  # magenta
    "\033[36m",  # cyan
    "\033[91m",  # light red
    "\033[92m",  # light green
    "\033[93m",  # light yellow
    "\033[94m",  # light blue
    "\033[95m",  # light magenta
    "\033[96m",  # light cyan
]


def print_log(
    event: Dict[str, str],
    payload: str,
    event_type: str,
    *,
    use_color: bool = True,
    add_timestamp: bool = True,
):
    pid, name, group = int(event["pid"]), event["processname"], event["groupname"]
    log_out = {
        "PROCESS_LOG_STDOUT": "STDOUT",
        "PROCESS_LOG_STDERR": "STDERR",
    }.get(event_type)
    if log_out is None:
        return

    color = LOG_HEADER_COLOR[pid % len(LOG_HEADER_COLOR)] if use_color else ""
    color_reset = "\033[0m" if use_color else ""
    timestamp = datetime.now().isoformat() if add_timestamp else ""

    for line in payload.splitlines():
        write_stderr(
            f"{color}{timestamp} [{log_out}] {name} ({group}) | {color_reset}{line}{color_reset}\n"
        )
    return


if __name__ == "__main__":
    USE_COLOR = os.environ.get("USE_COLOR", "true").lower() == "true"
    ADD_TIMESTAMP = os.environ.get("ADD_TIMESTAMP", "true").lower() == "true"
    while True:
        write_stdout("READY\n")
        header, event, payload = receive_input()
        write_stdout("RESULT 2\nOK")
        print_log(
            event,
            payload,
            header["eventname"],
            use_color=USE_COLOR,
            add_timestamp=ADD_TIMESTAMP,
        )
