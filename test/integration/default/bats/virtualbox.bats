#!/usr/bin/env bats

@test "create and start empty vbox" {
    vboxmanage createvm --name test --basefolder /tmp --register
    # created vm is registered
    vboxmanage list vms | grep test
    # start it
    vboxmanage startvm test --type headless
    vboxmanage list runningvms | grep test
    vboxmanage controlvm test poweroff
    vboxmanage unregistervm test --delete
}

@test "extpack installed" {
    vboxmanage list extpacks | grep Usable | grep true
}

@test "webservice is listening on localhost" {
    printf "q close\n" | telnet -e q 127.0.0.1 18083
}

@test "webservice user has uid 945" {
    cat /etc/passwd | grep vboxwebsrv: | grep 945
}

@test "webservice home directory" {
    cat /etc/passwd | grep vboxwebsrv | grep /var/lib/vboxwebsrv
    test -d /var/lib/vboxwebsrv
    su vboxwebsrv -c "vboxmanage createvm --name test --register" -s /bin/bash
    test -e /var/lib/vboxwebsrv/VirtualBox\ VMs/test/test.vbox
    su vboxwebsrv -c "vboxmanage unregistervm test --delete" -s /bin/bash
}

@test "phpvirtualbox available" {
    test -e /srv/phpvirtualbox/index.html
}

@test "phpvirtualbox user management" {
    wget -O - 192.168.33.53/phpvirtualbox/lib/ajax.php --post-data='fn=login&u=bert&p=bert'|fgrep bert
    wget -O - 192.168.33.53/phpvirtualbox/lib/ajax.php --post-data='fn=login&u=ernie&p=plain-pillar-password'|fgrep ernie
    wget -O - 192.168.33.53/phpvirtualbox/lib/ajax.php --post-data='fn=login&u=bert&p=b'|fgrep responseData\":[] 
}
