"""Test runner for the CoolNet AI LLM explanation layer."""

import os
import sys
import unittest

# Ensure the root Coolnet directory is on sys.path
current_dir = os.path.dirname(os.path.abspath(__file__))
root_dir = os.path.abspath(os.path.join(current_dir, "..", ".."))
if root_dir not in sys.path:
    sys.path.insert(0, root_dir)


def run_all_tests() -> bool:
    """Discover and run all test modules in the llm/tests directory."""
    loader = unittest.TestLoader()
    suite = loader.discover(start_dir=current_dir, pattern="test_*.py")

    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    return result.wasSuccessful()


if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)
