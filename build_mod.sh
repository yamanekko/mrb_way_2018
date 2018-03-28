#!/bin/sh
rm app_ruby.h
rm balance_ruby.h
rm watch_ruby.h

/Users/yuri/git/mruby/bin/mrbc -g -Bbcode -oapp_ruby.h app_ruby2.rb
/Users/yuri/git/mruby/bin/mrbc -g -Bcyccode -obalance_ruby.h balance2.rb
/Users/yuri/git/mruby/bin/mrbc -g -Bwatchcode -owatch_ruby.h watch.rb
cd ..
make clean
make app=mrb_way2018-2

# rename app ->mruby_way
cp app 2018mruby_way2

cp 2018mruby_way2 /Volumes/SD/ev3rt/apps/2018mruby_way2
diskutil umount /Volumes/SD
