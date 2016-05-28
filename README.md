# HandHQReader
# How to use
### 1. Install MySQL on you mac computer
for example.
```
brew install mysql
```

### 2. Clone this repository
```
cd ~/dev
git clone https://github.com/ishikota/HandHQReader/edit/master/README.md
```

### 3. Download handhq hand history data
Below command download zipped data below `HandHQReader/raw_data`
```
cd ~/dev/HandHQReader
./script/download/download_zipped_data
```

### 4. Setup database to store hand history
**[Be caful!!] below script try to create handhq db by root user**
```
cd ~/dev/HandHQReader
./script/reconstruct_db
```

### 5. Import hand history data into database
Below script reads all handhq history file and write into handhq database.
```
cd ~/dev/HandHQReader
ruby script/import/import_all_raw_data.rb
```
