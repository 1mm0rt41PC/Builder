# -*- mode: python ; coding: utf-8 -*-

import os
block_cipher = pyi_crypto.PyiBlockCipher(key=os.environ['pykey'])


a = Analysis(['./cme/crackmapexec.py'],
             pathex=['./cme'],
             binaries=[],
             datas=[('./cme/protocols', 'cme/protocols'),('./cme/data', 'cme/data'),('./cme/modules', 'cme/modules')],
             hiddenimports=['unicrypto.backends.pycryptodomex','cryptography', 'cffi', 'cryptography.hazmat.backends.openssl', 'cryptography.hazmat.bindings._openssl', 'unicrypto', 'unicrypto.backends.pycryptodome.DES', 'unicrypto.backends.pycryptodome.TDES', 'unicrypto.backends.pycryptodome.AES', 'unicrypto.backends.pycryptodome.RC4', 'unicrypto.backends.pure.DES', 'unicrypto.backends.pure.TDES', 'unicrypto.backends.pure.AES', 'unicrypto.backends.pure.RC4', 'unicrypto.backends.cryptography.DES', 'unicrypto.backends.cryptography.TDES', 'unicrypto.backends.cryptography.AES', 'unicrypto.backends.cryptography.RC4', 'unicrypto.backends.pycryptodomex.DES', 'unicrypto.backends.pycryptodomex.TDES', 'unicrypto.backends.pycryptodomex.AES', 'unicrypto.backends.pycryptodomex.RC4', 'unicrypto.backends.pycryptodomex','aardwolf.commons.factory','aardwolf.commons','aardwolf','cme.helpers.bloodhound','cme.protocols.mssql.mssqlexec', 'cme.connection', 'impacket.examples.secretsdump', 'impacket.dcerpc.v5.lsat', 'impacket.dcerpc.v5.transport', 'impacket.dcerpc.v5.lsad', 'cme.servers.smb', 'cme.protocols.smb.wmiexec', 'cme.protocols.smb.atexec', 'cme.protocols.smb.smbexec', 'cme.protocols.smb.mmcexec', 'cme.protocols.smb.smbspider', 'cme.protocols.smb.passpol', 'paramiko', 'pypsrp.client', 'pywerview.cli.helpers', 'impacket.tds', 'impacket.version', 'cme.helpers.bash', 'pylnk3', 'lsassy','win32timezone', 'impacket.tds', 'impacket.ldap.ldap', 'impacket.tds'],
             hookspath=['./cme/.hooks'],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=None)
exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          [],
          name=os.environ['_outTarget']+'_'+os.environ['_arch'],
          debug=False,
          bootloader_ignore_signals=False,
          strip=False,
          upx=True,
          upx_exclude=[],
          runtime_tmpdir=None,
          console=True,
          icon=os.environ['scriptpath']+'/pytools.ico' )
