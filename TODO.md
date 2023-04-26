In no particular order:

- [x] Setup Continuous Integration
- [x] Write SETUP.md under docs/
- [x] Write initial test suite infrastructure.
    - [ ] Integrate `test.R` & `test.py`
    - [ ] Come up with a better system than the shell script.
    - [ ] Add futhark specific tests (pure performance benchmarks, as opposed to accuracy benchmarks).
- [x] Decide on a License, likey MIT/ISC/BSD.
- [x] Setup a system for docs generation (Java Docs style?).
    - [ ] Eventually move to using Futhark's built in doc generator
- [ ] Add a `setup.py` script to allow for installing & building via python.
    - [ ] Consider adding a workflow to publish to pypi after: https://github.com/marketplace/actions/pypi-publish
    - [ ] Consider restructuring the folder structure to allow this library to be easily imported into other futhark programs.
- [ ] Figure out how to keep CI from downloading pip pkgs every run
- [x] Figure out how to keep CI from downloading futhark every run
    ~~- [ ] Create a custom github action to setup futhark~~
- [ ] Figure out how to have CI automatically publish docs
