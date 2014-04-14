# Cloud Storage Uploader

Uploads a (larger) file in a minimum of time by streaming.

Very basic. It's only working with Google Drive for now.

## Install

```sh
  $ git clone git@github.com:pstaender/csup.git csup
  $ cd csup && npm install .
  # if you want to use it from commandline everywhere (recommend)
  $ chmod +x lib/csup
  $ ln -s $(pwd)/lib/csup /usr/local/bin/csup
```

## Configuration and Authentication

Edit the config file and replace with your credentials:

```sh
  $ vim ~/.csub
```

```yaml
clientID: ***.apps.googleusercontent.com
clientSecret: ***
redirectURL: http://localhost
```

Now we need to request the accesstoken from google (will be stored in `~/.csub` by default):

```sh
  $ csup auth
  Visit the url:
  https://accounts.google.com/o/oauth2/auth?scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive.file&response_type=code&client_id=***vs.apps.googleusercontent.com&redirect_uri=http%3A%2F%2Flocalhost
  Enter the code here: 
```
Visit the given url and enter the code which is given in the browser url after granting access (e.g. http://localhost/?code=**4/6Lu5yZys3A4fFmVDcEF-hSKxrHs-.EsFadx5GgeweOl05ti2ZT3YjGrG6igI**). Done.

## Usage

Sending a (large) file:

```sh
  $ cat video.mkv | csup upload
  * 0B_eNw266a3FwRVZjaGNPVnVTbzQ-> file_1397434048983
```

or by giving a filename (recommend):

```sh
  $ cat james_bond.mkv | csup upload -n JamesBond.mkv
  * 0B_eNw266a3FwRVZjaGNPVnVTbzQ -> JamesBond.mkv
```

and a filetype:

```sh
  $ cat README.md | csup upload -n README.md -t text/troff
  * 0B_eNw266a3FwRVZjaGNPVnVTbzQ -> README.md
```

## Best practices

Tar and zip a (larg) folder, encrypt it and send it directly to your Google Drive: 

```sh
  $ tar cz folder_to_encrypt | openssl enc -aes-256-cbc -e -pass pass:mypass | csup upload -n out.tar.gz.enc
```

After downloading the file from Google Drive, ecrypting and deflating would be:

```sh
  $ openssl enc -d -aes-256-cbc -in out.tar.gz.enc -pass pass:mypass | out.tar.gz | tar xz
```

## Further docs

  * https://code.google.com/apis/console/
  * https://developers.google.com/oauthplayground/

## License

MIT License 
