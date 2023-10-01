import runpy,sys;
#sys.path.append(r'C:\py3\Scripts')

bin_src=sys.argv[0]
if bin_src.lower().startswith('impacker'):
	if len(sys.argv) <= 1:
		print(f'Usage:\n\t{sys.argv[0]} <addcomputer|atexec|dcomexec|dpapi|esentutl|exchanger|findDelegation|Get-GPPPassword|GetADUsers|getArch|GetNPUsers|getPac|getST|getTGT|GetUserSPNs|goldenPac|karmaSMB|keylistattack|kintercept|lookupsid|machine_role|mimikatz|mqtt_check|mssqlclient|mssqlinstance|netview|ntfs-read|ntlmrelayx|psexec|raiseChild|rbcd|rdp_check|reg|registry-read|rpcdump|rpcmap|sambaPipe|samrdump|secretsdump|services|smbclient|smbexec|smbpasswd|smbrelayx|smbserver|ticketConverter|ticketer|tstool|wmiexec|wmipersist|wmiquery>')
		sys.exit(1)
	else:
		bin=sys.argv[1]
		del sys.argv[1]
		print(sys.argv)
else:
	bin=sys.argv[0].replace('.exe','')
	

# pcapy pyreadline
# set hiddenimports= --hidden-import Get-GPPPassword --hidden-import ntfs-read --hidden-import registry-read

import addcomputer
import atexec
import dcomexec
import dpapi
import esentutl
import exchanger
import findDelegation
__import__('Get-GPPPassword')
import GetADUsers
import getArch
import GetNPUsers
import getPac
import getST
import getTGT
import GetUserSPNs
import goldenPac
import karmaSMB
import keylistattack
import kintercept
import lookupsid
import machine_role
import mimikatz
import mqtt_check
import mssqlclient
import mssqlinstance
import netview
#import nmapAnswerMachine
__import__('ntfs-read')
import ntlmrelayx
#import ping
#import ping6
import psexec
import raiseChild
import rbcd
import rdp_check
import reg
__import__('registry-read')
import rpcdump
import rpcmap
import sambaPipe
import samrdump
import secretsdump
import services
import smbclient
import smbexec
import smbpasswd
import smbrelayx
import smbserver
#import sniff
#import sniffer
#import split
import ticketConverter
import ticketer
import tstool
import wmiexec
import wmipersist
import wmiquery



runpy.run_module(bin, run_name='__main__')


