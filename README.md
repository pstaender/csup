# Cloud Storage Uploader

Uploads (large) data trough the pipe to Google Drive.

Very basic and it's only working with GDrive for now.

You can use only `stdin` / pipe as source (there won't be the feature to send a file by parameter like `csup upload file_to_send.txt`). The tool … is doing great in that job. 

## Install

```sh
  $ npm install -g csup
```

Take a quick look at **Configuration and Authentication** (below) before using it.

## Configuration and Authentication

Simply run

```sh
  $ csup setup
```

## How to create a clientID and clientSecret

## Commands

```sh
  $ csup help

  Usage: csup (switch) (-option|--option)

  switches:
    auth        receives `accessToken` from Google API (interactive)
    setup       setups `clientID` + `clientSecret` (interactive)
    filename    returns a filename; usage: csup filename $id
    download    downloads a file;   usage: csup download $id > filename.txt

  options:
    -h --help   displays help
    -n --name   filename for cloud storage    e.g. -n filename.txt
    -t --type   force a specific filetype     e.g. -t 'application/zip'
    -v -vv      verbosity
```

## Examples

Process (large) data and pipe them to cloud storage:

```sh
  $ do_something | do_some_other_stuff | … | csup -n output.txt
```

Uploading a log file and zip it:

```sh
  $ cat /var/log/service.log | grep error | gzip | csup -n "log.gz"
  0B_aNw316e3FwdXEwXEdCMnlVaW8
```

If you prefere more verbosity:

```sh
  $ cat /var/log/service.log | grep error | gzip | csup -vn "log.gz"
  * 0B_aNw316e3FwdXEwXEdCMnlVaW8 -> log.gz (1.2mb)
```

If you prefer more verbosity:

```sh
  $ cat /var/log/service.log | grep error | gzip | csup -vvn "log.gz"
  { id: '0B_aNw316e3FwdXEwXEdCMnlVaW8',
  filename: 'log.gz',
  mimeType: 'application/x-gzip; charset=UTF-8',
  downloadUrl: 'https://doc-0o-9s-docs.googleusercontent.com/docs/securesc/…?h=…&e=download&gd=true',
  createdDate: '2014-04-14T12:36:40.200Z',
  modifiedDate: '2014-04-14T12:36:40.021Z',
  md5Checksum: '92e4e5e7834dc754186f07c8e868dbf9',
  fileSize: 1234567,
  originalFilename: 'Untitled',
  ownerNames: [ 'OwnerName' ] }
  * 0B_aNw316e3FwdXEwXEdCMnlVaW8 -> log.gz (1.2mb)
```

Sending a large videofile could be

```sh
  $ cat video.mkv | csup
  * 0B_eNw266a3FwRVZjaGNPVnVTbzQ-> file_1397434048983 (320.2mb)
```

or by giving a filename (recommend):

```sh
  $ cat james_bond.mkv | csup -n JamesBond.mkv
  * 0B_eNw266a3FwRVZjaGNPVnVTbzQ -> JamesBond.mkv (320.2mb)
```

Force a specific filetype:

```sh
  $ cat README.md | csup -n README.md -t text/troff
```

Maybe the most valuable tool(s): tar and compress a folder, encrypt it and send it directly to your Google Drive: 

```sh
  $ tar cz folder_to_encrypt | openssl enc -aes-256-cbc -e -pass pass:mypass | csup -n backup_$(date +"%Y-%m-%d_%H:%M:%S_%Z").tar.gz.enc
```

For the rest of us who is not familiar with encrypting and decryption After downloading the file from Google Drive, ecrypting and deflating would be:

```sh
  $ openssl enc -d -aes-256-cbc -in out.tar.gz.enc -pass pass:mypass | out.tar.gz | tar xz
```

## Limitations

According to Google Drive API docs (http://) you are able to upload up to **1TB large files** if you are having that much free space available.

## Example #2 Incremental Backup with tar
http://www.gnu.org/software/tar/manual/html_node/Incremental-Dumps.html

## Further docs

  * https://code.google.com/apis/console/
  * https://developers.google.com/oauthplayground/

## License

MIT License 
