#!/bin/sh

/Users/xxx/git/mruby/bin/mrbc -g -Bbcode -oapp_ruby.h app_ruby2.rb
/Users/xxx/git/mruby/bin/mrbc -g -Bcyccode -obalance_ruby.h balance.rb
/Users/xxx/git/mruby/bin/mrbc -g -Bwatchcode -owatch_ruby.h watch.rb
cd ..
make clean
make mod=mrb_way

# rename app ->mruby_way 
cp app mruby_way

