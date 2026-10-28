#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
PYTHONPATH=src python -m gbt_energy_scheduler info
PYTHONPATH=src python -m gbt_energy_scheduler check --payload '{}'
PYTHONPATH=src python -m gbt_energy_scheduler run   --payload '{}'
