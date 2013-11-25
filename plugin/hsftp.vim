" Title: hsftp
" Description: Upload and download files through sftp
" Usage: :Hupload and :Hdownload
"        By default mapped to
"        <leader>hsd (hsftp download) and
"        <leader>hsu (hsftp upload)
"        See README for more
" Github: https://github.com/hesselbom/vim-hsftp
" Author: Viktor Hesselbom (hesselbom.net)
" License: MIT

function! h:GetConf()
  let conf = {}

  let l:configpath = expand('%:p:h')
  let l:configfile = l:configpath . '/.hsftp'
  let l:foundconfig = ''
  if filereadable(l:configfile)
    let l:foundconfig = l:configfile
  else
    while !filereadable(l:configfile)
      let slashindex = strridx(l:configpath, '/')
      if slashindex >= 0
        let l:configpath = l:configpath[0:slashindex]
        let l:configfile = l:configpath . '.hsftp'
        let l:configpath = l:configpath[0:slashindex-1]
        if filereadable(l:configfile)
          let l:foundconfig = l:configfile
          break
        endif
        if slashindex == 0 && !filereadable(l:configfile)
          break
        endif
      else
        break
      endif
    endwhile
  endif

  if strlen(l:foundconfig) > 0
    let options = readfile(l:foundconfig)
    for i in options
      let vname = substitute(i[0:stridx(i, ' ')], '^\s*\(.\{-}\)\s*$', '\1', '')
      let vvalue = substitute(i[stridx(i, ' '):], '^\s*\(.\{-}\)\s*$', '\1', '')
      let conf[vname] = vvalue
    endfor

    let conf['local'] = fnamemodify(l:foundconfig, ':h:p') . '/'
    let conf['localpath'] = expand('%:p')
    let conf['remotepath'] = conf['remote'] . conf['localpath'][strlen(conf['local']):]
  endif

  return conf
endfunction

function! h:DownloadFile()
  let conf = h:GetConf()

  if has_key(conf, 'host')
    let action = printf('get %s %s', conf['remotepath'], conf['localpath'])
    let cmd = printf('expect -c "set timeout 5; spawn sftp -P %s %s@%s; expect \"*assword:\"; send %s\r; expect \"sftp>\"; send \"%s\r\"; expect -re \"100%\"; send \"exit\r\";"', conf['port'], conf['user'], conf['host'], conf['pass'], action)


    if conf['confirm_download'] == 1
      let choice = confirm('Download file?', "&Yes\n&No", 2)
      if choice != 1
        echo 'Canceled.'
        return
      endif
    endif

    execute '!' . cmd
  else
    echo 'Could not find .hsftp config file'
  endif
endfunction

function! h:UploadFile()
  let conf = h:GetConf()

  if has_key(conf, 'host')
    let action = printf('put %s %s', conf['localpath'], conf['remotepath'])
    let cmd = printf('expect -c "set timeout 5; spawn sftp -P %s %s@%s; expect \"*assword:\"; send %s\r; expect \"sftp>\"; send \"%s\r\"; expect -re \"100%\"; send \"exit\r\";"', conf['port'], conf['user'], conf['host'], conf['pass'], action)

    if conf['confirm_upload'] == 1
      let choice = confirm('Upload file?', "&Yes\n&No", 2)
      if choice != 1
        echo 'Canceled.'
        return
      endif
    endif

    execute '!' . cmd
  else
    echo 'Could not find .hsftp config file'
  endif
endfunction

function! h:UploadFolder()
  let conf = h:GetConf()

  " execute "! echo " . file
  " let conf['localpath'] = expand('%:p')
  let action = "send pwd\r;"
  if has_key(conf, 'host')
    for file in split(glob('%:p:h/*'), '\n')
      let conf['localpath'] = file
      let conf['remotepath'] = conf['remote'] . conf['localpath'][strlen(conf['local']):]
  
      if conf['confirm_upload'] == 1
        let choice = confirm('Upload file?', "&Yes\n&No", 2)
        if choice != 1
          echo 'Canceled.'
          return
        endif
      endif
      let action = action . printf('expect \"sftp>\"; send \"put %s %s\r\";', conf['localpath'], conf['remotepath'])
    endfor
    " let cmd = printf('expect -c "set timeout 5; spawn sftp -P %s %s@%s; expect \"*assword:\"; send %s\r; expect \"sftp>\"; send \"%s\r\"; expect -re \"100%\"; send \"exit\r\";"', conf['port'], conf['user'], conf['host'], conf['pass'], action)

    let cmd = printf('expect -c "set timeout 5; spawn sftp -P %s %s@%s; expect \"*assword:\"; send %s\r; %s expect -re \"100%\"; send \"exit\r\";"', conf['port'], conf['user'], conf['host'], conf['pass'], action)

    execute '!' . cmd
  else
    echo 'Could not find .hsftp config file'
  endif

endfunction

command! Hdownload call h:DownloadFile()
command! Hupload call h:UploadFile()
command! Hupdir  call h:UploadFolder()

nmap <leader>hsd :Hdownload<Esc>
nmap <leader>hsu :Hupload<Esc>
nmap <leader>hsf :Hupdir<Esc>
