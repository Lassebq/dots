
install_firefox() {
    # make .mozilla/firefox/$USER the default profile
    mkdir -p ~/.mozilla/firefox/"$USER"

    echo "[Profile0]
Name=$USER
IsRelative=1
Path=$USER
Default=1
" > ~/.mozilla/firefox/profiles.ini

    echo "[$(echo $RANDOM | sha1sum | head -c 16)]
Default=$USER
Locked=1
" > ~/.mozilla/firefox/installs.ini

    if [ ! -d ~/.mozilla/firefox/"$USER"/chrome ]; then
        git clone https://github.com/black7375/Firefox-UI-Fix.git ~/.mozilla/firefox/"$USER"/chrome
    fi

    # userChrome and userContent need to be hardlinks. Firefox resolves path of soft links
    ln $PWD/config/firefox/*.css ~/.mozilla/firefox/"$USER"/chrome/
    ln -sf $PWD/config/firefox/css/*.css ~/.mozilla/firefox/"$USER"/chrome/css/
    ln -sf $PWD/config/firefox/user.js ~/.mozilla/firefox/"$USER"/user.js
}

install_firefox

