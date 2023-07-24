#!/usr/bin/env bash

clean_stuff () {
    sudo rm -rf /etc/accessaudit/
    sudo rm -f /etc/rsyslog.d/99-immudb-vault.conf
    echo "Installation removed. Goodbye."
    exit 0
}


while true; do
    read -p "Do you want to clean up your directory after a successful install? (y/n) " runvar

    case "$runvar" in
    [Yy]*)
        echo "Roger, cleaning it all up now..."
        clean_stuff
        echo "Restart rsyslog..."
        sudo systemctl restart rsyslog
        ;;
    [Nn]*)
        echo "Ok, terminating now..."
        exit
        ;;
    *)
        echo "Unrecognized selection: $runvar. y or n  " ;;
    esac
done
