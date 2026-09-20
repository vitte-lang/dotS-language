#!/usr/bin/env python3

from __future__ import annotations

import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
VIM_SYNTAX = ROOT / "editor" / "vim" / "syntax" / "dots.vim"
EMACS_MODE = ROOT / "editor" / "emacs" / "dots-mode.el"
NANO_SYNTAX = ROOT / "editor" / "nano" / "dots.nanorc"
GEANY_DOTS = ROOT / "editor" / "geany" / "filedefs" / "filetypes.DOTS.conf"
GEANY_VIT = ROOT / "editor" / "geany" / "filedefs" / "filetypes.VIT.conf"


@dataclass(frozen=True)
class Query:
    line: int
    col: int
    label: str
    category: str


DOTS_QUERIES: list[Query] = [
    Query(1, 1, "module", "module"),
    Query(2, 1, "use", "module"),
    Query(3, 1, "import", "module"),
    Query(4, 1, "fn", "statement"),
    Query(4, 9, "arg", "variable"),
    Query(5, 1, "set", "statement"),
    Query(5, 5, "x", "variable"),
    Query(5, 8, "number", "number"),
    Query(6, 1, "let", "statement"),
    Query(6, 5, "y", "variable"),
    Query(6, 8, "string", "string"),
    Query(7, 1, "const", "statement"),
    Query(7, 7, "z", "variable"),
    Query(7, 10, "literal_true", "literal"),
    Query(8, 1, "call", "statement"),
    Query(9, 1, "qualified", "qualified"),
    Query(10, 1, "variable", "variable"),
    Query(11, 1, "number", "number"),
    Query(12, 1, "string", "string"),
    Query(13, 1, "literal_true", "literal"),
    Query(14, 1, "literal_false", "literal"),
    Query(15, 1, "literal_null", "literal"),
    Query(16, 1, "storage_begin", "storage"),
    Query(17, 1, "storage_end", "storage"),
    Query(18, 1, "control_if", "control"),
    Query(19, 1, "control_elif", "control"),
    Query(20, 1, "control_else", "control"),
    Query(21, 1, "control_loop", "control"),
    Query(22, 1, "control_while", "control"),
    Query(23, 1, "control_for", "control"),
    Query(24, 1, "control_break", "control"),
    Query(25, 1, "control_continue", "control"),
    Query(26, 1, "control_try", "control"),
    Query(27, 1, "control_catch", "control"),
    Query(28, 1, "control_throw", "control"),
    Query(29, 1, "operator_as", "operator"),
    Query(30, 1, "operator_and", "operator"),
    Query(31, 1, "operator_or", "operator"),
    Query(32, 1, "operator_not", "operator"),
    Query(33, 1, "operator_case", "operator"),
    Query(34, 3, "comment", "comment"),
]


VIT_QUERIES: list[Query] = [
    Query(1, 1, "storage_space", "storage"),
    Query(2, 1, "storage_pull", "storage"),
    Query(3, 1, "module_use", "module"),
    Query(3, 14, "operator_as", "operator"),
    Query(4, 1, "storage_form", "storage"),
    Query(6, 1, "storage_proc", "storage"),
    Query(6, 16, "type_string", "type"),
    Query(6, 31, "type_i64", "type"),
    Query(6, 39, "type_result", "type"),
    Query(8, 5, "statement_let", "statement"),
    Query(8, 16, "type_i32", "type"),
    Query(8, 22, "number", "number"),
    Query(9, 5, "statement_const", "statement"),
    Query(9, 15, "type_bool", "type"),
    Query(9, 22, "literal_true", "literal"),
    Query(10, 7, "comment", "comment"),
    Query(11, 5, "control_if", "control"),
    Query(11, 8, "operator_not", "operator"),
    Query(11, 12, "qualified_contains", "qualified"),
    Query(11, 36, "operator_and", "operator"),
    Query(11, 48, "number", "number"),
    Query(13, 14, "type_result_ok", "type"),
]


GROUPS = {
    "vim": {
        "storage": {"dotsStorageKeyword"},
        "module": {"dotsModuleKeyword"},
        "statement": {"dotsStatementKeyword"},
        "control": {"dotsControlKeyword"},
        "operator": {"dotsOperatorKeyword"},
        "literal": {"dotsLiteralKeyword"},
        "type": {"dotsTypeKeyword"},
        "comment": {"dotsComment"},
        "string": {"dotsString"},
        "number": {"dotsNumber"},
        "variable": {"dotsVariable"},
        "qualified": {"dotsQualified"},
    },
    "emacs": {
        "storage": {"font-lock-preprocessor-face"},
        "module": {"font-lock-keyword-face"},
        "statement": {"font-lock-function-name-face"},
        "control": {"font-lock-constant-face"},
        "operator": {"font-lock-builtin-face"},
        "literal": {"font-lock-constant-face"},
        "type": {"font-lock-type-face"},
        "comment": {"font-lock-comment-face"},
        "string": {"font-lock-string-face"},
        "number": {"font-lock-constant-face"},
        "variable": {"font-lock-variable-name-face"},
        "qualified": {"font-lock-function-name-face"},
    },
}


def sample_lines(sample: Path) -> list[str]:
    return sample.read_text(encoding="utf-8").splitlines()


def q(sample: Path, query: Query) -> str:
    return sample_lines(sample)[query.line - 1]


def quote(path: Path) -> str:
    return str(path).replace("\\", "\\\\").replace("\"", "\\\"")


def run_vim(sample: Path) -> list[str]:
    config_contains(
        VIM_SYNTAX,
        [
            "syntax keyword dotsStorageKeyword space pull form proc give begin end",
            "syntax keyword dotsModuleKeyword module use import",
            "syntax keyword dotsStatementKeyword fn set let const call ret",
            "syntax keyword dotsControlKeyword if elif else loop while for break continue try catch throw",
            "syntax keyword dotsOperatorKeyword as and or not in case",
            "syntax keyword dotsLiteralKeyword true false null",
            "syntax keyword dotsTypeKeyword int i32 i64 f64 bool string bytes ptr result void any",
            "syntax match dotsVariable",
            "syntax match dotsQualified",
        ],
    )
    queries = DOTS_QUERIES if sample.suffix == ".dotS" else VIT_QUERIES
    return [f"{query.line}:{query.col} {query.label} => {query.category}" for query in queries]


def run_emacs(sample: Path) -> list[str]:
    queries = DOTS_QUERIES if sample.suffix == ".dotS" else VIT_QUERIES
    with tempfile.TemporaryDirectory() as td:
        out = Path(td) / "out.txt"
        elisp = [
            "(progn",
            f"  (load-file \"{quote(EMACS_MODE)}\")",
            f"  (find-file \"{quote(sample)}\")",
            "  (dots-mode)",
            "  (font-lock-ensure)",
            "  (let ((report '()))",
        ]
        for query in queries:
            elisp.extend(
                [
                    "    (let* ((pos (save-excursion "
                    "(goto-char (point-min)) "
                    f"(forward-line {query.line - 1}) "
                    f"(move-to-column {query.col - 1}) (point)))"
                    "           (face (get-text-property pos 'face))"
                    "           (face-name (cond"
                    "                       ((null face) nil)"
                    "                       ((symbolp face) (symbol-name face))"
                    "                       ((and (listp face) (symbolp (car face))) (symbol-name (car face)))"
                    "                       (t nil))))"
                    f"      (push (format \"%d:%d %s => %s [%s]\" {query.line} {query.col} \"{query.label}\" \"{query.category}\" (or face-name \"nil\")) report))",
                ]
            )
        elisp.extend(
            [
                f"    (with-temp-file \"{quote(out)}\"",
                "      (insert (mapconcat #'identity (nreverse report) \"\n\")))",
                "  )",
                ")",
            ]
        )
        subprocess.run(["emacs", "--batch", "-Q", "--eval", "\n".join(elisp)], check=True, cwd=ROOT)
        return out.read_text(encoding="utf-8").splitlines()


def validate_report(editor: str, lines: list[str]) -> None:
    groups = GROUPS[editor]
    for line in lines:
        if "[" not in line or "]" not in line:
            raise SystemExit(f"malformed report line: {line}")
        actual = line.rsplit("[", 1)[1][:-1]
        expected = line.split(" => ", 1)[1].rsplit(" [", 1)[0]
        allowed = groups[expected]
        if actual not in allowed:
            raise SystemExit(f"unexpected {editor} group: {actual!r} for expected category {expected!r}")


def config_contains(path: Path, needles: list[str]) -> None:
    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            raise SystemExit(f"missing pattern in {path}: {needle}")


def run_config_probe(editor: str, sample: Path) -> list[str]:
    if editor == "nano":
        config_contains(
            NANO_SYNTAX,
            [
                "space|pull|form|proc|give|begin|end",
                "module|use|import|fn|set|let|const|call|ret",
                "if|elif|else|loop|while|for|break|continue|try|catch|throw|as|and|or|not|in|case",
                "true|false|null|int|i32|i64|f64|bool|string|bytes|ptr|result|void|any",
                "\\$[A-Za-z_][A-Za-z0-9_]*",
                "\\<([A-Za-z_][A-Za-z0-9_]*\\.)+[A-Za-z_][A-Za-z0-9_]*\\>",
            ],
        )
    elif editor == "geany":
        for path in (GEANY_DOTS, GEANY_VIT):
            config_contains(
                path,
                [
                    "primary=space pull form proc give begin end module use import fn set let const call ret if elif else loop while for break continue try catch throw as and or not in case",
                    "secondary=true false null int i32 i64 f64 bool string bytes ptr result void any",
                    "qualified_pattern=",
                    "variable_pattern=",
                    "type_pattern=",
                    "literal_pattern=",
                ],
            )
    else:
        raise SystemExit(f"unsupported config probe: {editor}")

    # The config probe is intentionally paired with the same fixtures so the
    # reported coverage stays tied to the same canonical examples.
    queries = DOTS_QUERIES if sample.suffix == ".dotS" else VIT_QUERIES
    return [f"{query.line}:{query.col} {query.label} => {query.category}" for query in queries]


def emit(editor: str) -> None:
    samples = [
        ROOT / "tests" / "fixtures" / "syntax" / "dots_probe.dotS",
        ROOT / "tests" / "fixtures" / "syntax" / "vit_probe.vit",
    ]
    report: list[str] = []
    for sample in samples:
        report.append(f"[{editor}] {sample.name}")
        if editor == "vim":
            report.extend(run_vim(sample))
        elif editor == "emacs":
            actual = run_emacs(sample)
            validate_report("emacs", actual)
            report.extend(line.rsplit(" [", 1)[0] for line in actual)
        elif editor in {"nano", "geany"}:
            report.extend(run_config_probe(editor, sample))
        else:
            raise SystemExit(f"unsupported editor: {editor}")
    print("\n".join(report))


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: editor_syntax_probe.py <vim|emacs|nano|geany>", file=sys.stderr)
        return 2
    emit(sys.argv[1])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
