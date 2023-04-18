#!/bin/sh

cat << EOF | R --no-save > /dev/null
data('iris')
write.csv(iris, "iris.csv")
EOF

sqlite3 "iris.sqlite3" -cmd ".mode csv" ".import --csv iris.csv MAIN"

sqlite3 iris.sqlite3 -cmd "select \"Sepal.Length\" from MAIN" ".exit" |
      tr '\n' ',' | sed -e "s/^/sepal_length = np.array([/" -e "s/,$/])\n/"

sqlite3 iris.sqlite3 -cmd "select \"Sepal.Width\" from MAIN" ".exit" |
      tr '\n' ',' | sed -e "s/^/sepal_width = np.array([/" -e "s/,$/])\n/"

sqlite3 iris.sqlite3 -cmd "select \"Petal.Length\" from MAIN" ".exit" |
      tr '\n' ',' | sed -e "s/^/petal_length = np.array([/" -e "s/,$/])\n/"

sqlite3 iris.sqlite3 -cmd "select \"Petal.Width\" from MAIN" ".exit" |
      tr '\n' ',' | sed -e "s/^/petal_width = np.array([/" -e "s/,$/])\n/"

for s in setosa versicolor virginica; do
    sqlite3 iris.sqlite3 -cmd "select \"Sepal.Length\" from MAIN where \"Species\" = \"$s\"" ".exit" |
          tr '\n' ',' | sed -e "s/^/sepal_length_$s = np.array([/" -e "s/,$/])\n/"
done

rm iris.sqlite3
rm iris.csv
