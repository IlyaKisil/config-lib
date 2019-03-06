This directory contains configuration files with user settings for Jupyter Lab and Jupyter Notebook

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents** generated with [DocToc](https://github.com/thlorenz/doctoc) 

Last Update: 2019-03-06

- [Overall thoughts](#overall-thoughts)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->




## Overall thoughts
-   It is better to have Jupyter Lab/Notebook installed in the base environment
-   Since, it will always be launched from it, then all extensions and the corresponding user settings need to be specified in the config files related to this base environment.
-   In order to use venv different from the base environment, need to use `ipykernel` in order to create a kernel for this venv.
-   This code snippet is a part of [`create_venv.sh`](https://github.com/IlyaKisil/config-lib/blob/master/scripts/create_venv.sh) script and it works for me just fine:
    ```
    $VENV="my_name"

    source activate ${VENV}

    pip install ipykernel # can use conda as well

    python -m ipykernel install --user --name ${VENV} --display-name ${VENV}

    source deactivate
    ```
