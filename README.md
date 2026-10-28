# energy_scheduler

**One capability bit from GBT V8, packaged standalone.** No. 127 of 341,
`llm` domain (LLM).

<p>
<img alt="python" src="https://img.shields.io/badge/python-3.9%2B-blue">
<img alt="license" src="https://img.shields.io/badge/license-MIT-green">
<img alt="deps" src="https://img.shields.io/badge/runtime%20dependencies-0-brightgreen">
</p>

> 能源调度面（蒸馏自 2026-09-28 主人给的周榜卡 vllm 92.7k★，只取**调度架构**，不引 CUDA 内核——本机零算力造了也是空壳）：批量 prompt → 多能源分配（**每源并发上限** 按池内 status 档 · **失败冷却** 同源连败 3 次 ⇒ 300s 不再派 · **公平** least-load 优先不饿死单源）。`plan` **纯本地不出网**（可单测可审计）· `run` 每一发都过唯一门 `llm_chat`（external_llm 闸管，没票逐发如实记拒绝）· `status` 计划/源/冷却读数。op=plan/run/status/where

That description is copied verbatim from the registry. `tests/test_spec.py` pins it,
so documentation drift fails the build instead of shipping quietly.

## What this package actually is

It is the **contract** for one capability: its name, its parameters, the values it
accepts, and whether it can change state that cannot be restored. It is not the
implementation — that lives in the runtime this bit was extracted from.

So `run()` goes through a narrow `Backend` protocol, and the default backend is a
stub that **says so**:

```
status="validated"   backend="stub"   data={"executed": false}
```

Never `status="ok"`. A stub that reports success is worse than no stub, because the
caller stops looking for the real thing.

## Install

```bash
git clone https://github.com/gbtweilai-star/gbt-energy-scheduler.git
cd gbt-energy-scheduler
python -m pip install -e ".[dev]"
```

## Use

```bash
python -m gbt_energy_scheduler info                  # capability card
python -m gbt_energy_scheduler spec --json           # machine-readable contract
python -m gbt_energy_scheduler check --payload '{}'
python -m gbt_energy_scheduler run   --payload '{}'
```

Real `info` output from this machine:

```text
energy_scheduler  (llm)  v1.0.0
----------------------------------------
能源调度面（蒸馏自 2026-09-28 主人给的周榜卡 vllm 92.7k★，只取**调度架构**，不引 CUDA 内核——本机零算力造了也是空壳）：批量 prompt → 多能源分配（**每源并发上限** 按池内 status 档 · **失败冷却** 同源连败 3 次 ⇒ 300s 不再派 · **公平** least-load 优先不饿死单源）。`plan` **纯本地不出网**（可单测可审计）· `run` 每一发都过唯一门 `llm_chat`（external_llm 闸管，没票逐发如实记拒绝）· `status` 计划/源/冷却读数。op=plan/run/status/where

gated      : False
external   : False
multi-op   : True
params     : (none)
values     : plan, run, status, where
```

Wire a real implementation:

```python
from gbt_energy_scheduler import run

class MyBackend:
    name = "my-backend"
    def invoke(self, cap, payload):
        return {"cap": cap, "handled": sorted(payload)}

result = run({}, backend=MyBackend())
assert result.status == "ok"
```

## Parameters

| name | required | notes |
|---|---|---|
| — | no | the registry declares no required parameters |

Registry hint (`params_hint`): (empty)

**注册表登记的取值 / 子动作（4 个）**：`plan`、`run`、`status`、`where`

Types are deliberately absent: the registry does not declare them, and an invented
type is worse than no type, because callers believe it.

## Boundaries

- Not gated: the registry marks this bit `safe: true`.
- No external service dependency declared.
- Multi-op (`multi_op: true`): several sub-actions share one name — read `op` before calling.
- No implementation ships here. Bring a backend; the protocol is one method.

## What this is not

Not a wrapper around a hosted API. Not a model. Not a promise that calling it does
anything on its own. It is the typed seam plus the validation, which is the part that
stays correct even when the implementation changes.

## Tests

```bash
python -m pytest
```

```text
20 passed, 3 skipped in 0.11s
```

## Provenance

| field | value |
|---|---|
| capability | `energy_scheduler` |
| domain | `llm` |
| handler | `energy_scheduler` |
| safe | `True` (gated = `False`) |
| external | `False` |
| atlas page | [llm/energy_scheduler](https://github.com/gbtweilai-star/gbt-caps/blob/main/caps/llm/energy_scheduler.md) |
| full index | [https://github.com/gbtweilai-star/gbt-caps](https://github.com/gbtweilai-star/gbt-caps) |

The parent README says 348 capabilities; an AST pass over the registry enumerates
`341 + 0 unimplemented + 0 disabled = 341`. The extra 7 are historical duplicates.
Numbering here follows 341 and matches the `gbt-caps` index one-to-one.

## License

MIT.
