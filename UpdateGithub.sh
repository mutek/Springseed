#!/usr/bin/env sh
#
# UpdateGithub.sh
#
#
# Copyleft 2013 Luca Cappelletti <luca.cappelletti@gmail.com>
#
# DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
# Version 2, December 2004
#
# Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>
#
# Everyone is permitted to copy and distribute verbatim or modified
# copies of this license document, and changing it is allowed as long
# as the name is changed.
#
# DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
# TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
# 0. You just DO WHAT THE FUCK YOU WANT TO.
#

APPNAME="Springseed"

git config --global user.name "mutek"
git config --global user.email mutek@inventati.org

echo "Aggiungo i cambiamenti al database locale"
git add .
echo "Inserisci una descrizione dei tuoi cambiamenti"
read n
echo "Eseguo la finalizzazione dei cambiamenti in locale"
git commit -a -m "$n"

echo "Invio i cambiamenti locali al deposito remoto..."
git push origin master
echo "ok"


# official GitHub tips:
#
#Create a new repository on the command line
#
#touch README.md
#git init
#git add README.md
#git commit -m "first commit"
#git remote add origin https://github.com/mutek/$APPNAME.git
#git push -u origin master
#
#Push an existing repository from the command line
#
#git remote add origin https://github.com/mutek/$APPNAME.git
#git push -u origin master


