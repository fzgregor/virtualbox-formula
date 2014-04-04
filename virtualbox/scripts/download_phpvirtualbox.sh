#!/bin/bash

function check_requirements {
    which unzip &> /dev/null
    if [ $? -ne 0 ]; then
        echo "unzip program not found!"
        exit 1
    fi
}

# get the link for the download of a certain version of phpvirtualbox
# arg1 is the virtualbox base version (4.x)
function get_download_link {
    content=`wget -qO - http://sourceforge.net/projects/phpvirtualbox/files/`
    if [ $? -ne 0 ]; then
        echo "download of the download overview page http://sourceforge.net/projects/phpvirtualbox/files/ failed! wget exit code $?"
        exit 1
    fi
    download_links=`echo "$content" | grep "http://sourceforge.net/projects/phpvirtualbox/files/"`
    if [ $? -ne 0 ]; then
        echo "Couldn't find download links in website!"
        exit 1
    fi
    contains_the_link=`echo "$download_links" | grep $1`
    if [ $? -ne 0 ]; then
        echo "failed to find a link for the version of phpvirtualbox you requested ($1)"
        exit 1
    fi
    count=`echo "$contains_the_link" | wc -l`
    if [ $count -ne 1 ]; then
        echo "found not one but $count download links for your version..."
        exit 1
    fi
    echo `echo "$contains_the_link" | sed "s/.\+\(http:\/\/sourceforge.net\/projects\/phpvirtualbox\/files.\+.zip\).\+/\1/"`
}


download_link=`get_download_link $1`
# seems like we have a download link, let's start
cd /tmp
wget -O phpvirtualbox.zip $download_link
if [ $? -ne 0 ]; then
    echo "error while downloading phpvirtualbox archive"
    # try to remove partial downloaded files
    rm phpvirtualbox.zip
    exit 1
fi

mkdir phpvirtualbox-extracted
cd phpvirtualbox-extracted
unzip ../phpvirtualbox.zip
if [ $? -ne 0 ]; then
    echo "could'nt extract archive"
    cd ..
    rm phpvirtualbox.zip
    rm -r phpvirtualbox-extracted
    exit 1
fi

# copy files to destination
mkdir -p $2
if [ ! -f "./index.html" ]; then
    d=`ls | grep phpvirtualbox`
    mv $d/* $2
else
    mv * $2
fi

# cleanup
cd ..
rm phpvirtualbox.zip
rm -r phpvirtualbox-extracted
