#!/bin/sh
rm app_ruby.h
rm balance_ruby.h
rm watch_ruby.h

/Users/yuri/git/mruby/bin/mrbc -g -Bbcode -oapp_ruby.h app_ruby2.rb
/Users/yuri/git/mruby/bin/mrbc -g -Bcyccode -obalance_ruby.h balance2.rb
/Users/yuri/git/mruby/bin/mrbc -g -Bwatchcode -owatch_ruby.h watch.rb

# mrbcで生成されたバイトコードに含まれている "extern const uint8_t" を消去するための暫定処理 
# mrubyが修正された場合は不要になる。残していても害はないはず
ruby delete_extern.rb

cd ..
make clean
make app=mrb_way_2018

# rename app ->mruby_way
cp app mruby_way_2018

# SDカードをPCに挿してコピーしたいときはここを使う
# cp 2018mruby_way /Volumes/SD/ev3rt/apps/mruby_way_2018
# diskutil umount /Volumes/SD
