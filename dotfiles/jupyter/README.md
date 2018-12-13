# Last update 13.12.2018
This directory contains configuration files with user settings for Jupyter Lab and Jupyter Notebook

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
