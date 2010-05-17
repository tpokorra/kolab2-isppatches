#!/bin/bash
cp *.png $1;
cd $1;
for i in $(ls *.html); do 
   sed -e 's/\.gif/\.png/g' <$i >tmp
   mv tmp $i
done
exit 0;
