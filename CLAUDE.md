# ntu.yiidtw

This is an aide agent instance. You are running as `ntu.yiidtw`.

## Memory

Your persistent memory lives in `cognition/memory/`. Read and write there.

@cognition/memory

## Memory Write Rules

NEVER write to `cognition/memory/` without evidence. Evidence means:
- A skill was executed and returned output proving the claim
- The output is included in the memory entry

If you cannot produce skill output as evidence, do NOT update memory.
When in doubt, open a GitHub issue on this repo with the evidence first.
