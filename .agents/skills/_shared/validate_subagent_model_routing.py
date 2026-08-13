#!/usr/bin/env python3
"""Validate that orchestrating skills use the shared model-routing policy."""

from pathlib import Path


SKILLS_ROOT = Path(__file__).resolve().parent.parent
POLICY_REFERENCE = "../_shared/subagent-model-routing.md"
ORCHESTRATORS = ("architect", "how", "why")
STALE_MODEL_NAMES = (
    "claude-fable",
    "claude-opus",
    "grok-4.5",
    "configured architect runners",
    "configured how-critics",
    "configured how-explainer",
    "configured how-explorer",
    "configured why-investigators",
    "configured why-synthesizer",
    "spawn multiple models",
)


def main() -> None:
    errors: list[str] = []

    policy_path = Path(__file__).with_name("subagent-model-routing.md").resolve()
    policy = policy_path.read_text(encoding="utf-8")
    for model in ("gpt-5.6-luna", "gpt-5.6-sol"):
        if model not in policy:
            errors.append(f"shared policy does not define {model}")

    for skill_name in ORCHESTRATORS:
        skill_path = SKILLS_ROOT / skill_name / "SKILL.md"
        skill = skill_path.read_text(encoding="utf-8")

        if POLICY_REFERENCE not in skill:
            errors.append(f"{skill_path}: missing shared policy reference")

        referenced_policy = (skill_path.parent / POLICY_REFERENCE).resolve()
        if referenced_policy != policy_path:
            errors.append(f"{skill_path}: policy reference resolves incorrectly")

        if "`gpt-" in skill:
            errors.append(f"{skill_path}: declares a model outside the shared policy")

        for stale_name in STALE_MODEL_NAMES:
            if stale_name in skill:
                errors.append(f"{skill_path}: stale model setting {stale_name!r}")

    if errors:
        raise SystemExit("\n".join(errors))

    print("Subagent model routing is consistent across architect, how, and why.")


if __name__ == "__main__":
    main()
