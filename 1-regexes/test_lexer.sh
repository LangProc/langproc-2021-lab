#!/bin/bash

# Try to find a portable way of getting rid of
# any stray carriage returns
if which dos2unix ; then
    DOS2UNIX="dos2unix"
elif which fromdos ; then
    DOS2UNIX="fromdos"
else
    >&2 echo "warning: dos2unix is not installed."
    # This should work on Linux and MacOS, it matches all the carriage returns with sed and removes
    # them.  Something similar could be implemented with `tr` if necessary or worst case it could be
    # disabled by substituting it with `cat`.
    DOS2UNIX="sed -e 's/\r//g'"
    # DOS2UNIX="tr -d '\r'"
    # DOS2UNIX="cat"
fi

echo "========================================"
echo " Cleaning the temporaries and outputs"
make clean
echo " Force building histogram"
make histogram -B
if [[ "$?" -ne 0 ]]; then
    echo "Build failed.";
fi
echo ""
mkdir -p test/out

echo "========================================="

PASSED=0
CHECKED=0

for i in test/in/*.txt; do
    echo "==========================="
    echo ""
    echo "Input file : ${i}"
    BASENAME=$(basename $i .txt);
    cat $i | ${DOS2UNIX} | ./histogram  > test/out/$BASENAME.stdout.txt  2> test/out/$BASENAME.stderr.txt

    diff <(cat test/ref/$BASENAME.stdout.txt | ${DOS2UNIX}) <(cat test/out/$BASENAME.stdout.txt) > test/out/$BASENAME.diff.txt
    if [[ "$?" -ne "0" ]]; then
        echo -e "\nERROR"
    else
        PASSED=$(( ${PASSED}+1 ));
    fi
    CHECKED=$(( ${CHECKED}+1 ));
done


echo "########################################"
echo "Passed ${PASSED} out of ${CHECKED}".
echo ""

case "$(uname -s)" in
    Darwin)
        echo ""
        echo "Warning: This appears not to be a Linux environment"
        echo "         Make sure you do a final run on a lab machine or an Ubuntu VM"
        exit 0
        ;;
esac

RELEASE=$(lsb_release -d)
if [[ $? -ne 0 ]]; then
    echo ""
    echo "Warning: This appears not to be a Linux environment"
    echo "         Make sure you do a final run on a lab machine or an Ubuntu VM"
else
    grep -q "Ubuntu 16.04" <(echo $RELEASE)
    FOUND=$?

    if [[ $FOUND -ne 0 ]]; then
        echo ""
        echo "Warning: This appears not to be the target environment"
        echo "         Make sure you do a final run on a lab machine or an Ubuntu VM"
    fi
fi
