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
