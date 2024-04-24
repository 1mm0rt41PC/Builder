#!C:\Python310-x64\python.exe
from subprocess import Popen,PIPE
import os,sys,shutil
from glob import glob
import random,string,tempfile
from datetime import datetime
import re
from time import sleep
import msvcrt # Windows file locking

IS_APPVEYOR = 'AVVM_DOWNLOAD_URL' in os.environ

myHelp = re.sub('`([^`\r\n]+)`', '\033[44;1m\\1\033[0m', f'''
`{sys.argv[0]} -h`
	> Show help
	
`{sys.argv[0]} -l`
	> List avaible repo to build

`{sys.argv[0]} myRepo <list|-l|-list|--list>`
	> List avaible exe for `myRepo` to build	
	
`{sys.argv[0]} [-j] myRepo/myExe`
	> Build the binary `myExe` from repo `myRepo`. `-j` Is for internal usage for threading support.

`{sys.argv[0]}`
	> Build all
''')

args = {
	'repo': None,
	'exe': None,
	'list': False,
	'job': False
}


def main() -> int:
	print(f'Envionement detected: IS_APPVEYOR={IS_APPVEYOR}')
	if len(sys.argv) > 1:
		if sys.argv[1] in ['help','-h','-help','--help']:
			print(myHelp)
			sys.exit(1)
		for a in sys.argv[1:]:
			if a in ['list','-l','-list','--list']:
				args['list'] = True
			elif a == '-j':
				args['job'] = True
			elif args['repo'] == None and not a.startswith('-'):
				if '/' in a:
					args['repo'],args['exe'] = a.split('/')
				else:
					args['repo'] = a
			else:
				print(f'Invalid argument {a}')
				print(myHelp)
				sys.exit(1)

	# Load Yaml
	try:
		import yaml
	except:
		init()# Init vars
		run(sys.executable+' -m pip install pyyaml')
		import yaml
		
	conf = None
	with open(os.path.dirname(os.path.realpath(__file__))+'/config.yml', 'r') as fp:
		conf = yaml.safe_load(fp.read())
	
	# Check if repo asked exist
	if args['repo'] and args['repo'] not in conf:
		args['list'] = True
		args['repo'] = False
		log_err('Unable to find the repo in the yaml !')
		log_err('List repos:')

	# List repo or exe in repo
	if args['list']:
		if not args['repo']:
			for itemName in conf:
				print(itemName)
			return 0
		for build in conf[args['repo']]:
			if build in ['build_py','build_csharp','build_cpp','build_rust','build_go','build_nim','build_custom']:
				print(args['repo']+'/'+(f'\n{args["repo"]}/'.join(conf[args['repo']][build].keys())).strip('\r\n \t'))
		return 0
	
	# Init vars
	init()	

	# Build the world
	for itemName in conf:
		if args['repo'] and (itemName != args['repo'] and itemName.lower() != args['repo']):
			continue
		print(f'[{itemName}] Building repo')
		for buildAction in conf[itemName]:
			actionName = list(buildAction.keys())[0]
			tasks = buildAction[actionName]

			if not args['job']:
				if actionName == 'clone':
					clone(tasks)
				elif actionName == 'chdir':
					chdir(tasks)
				elif actionName == 'replace':
					replace(tasks[0], tasks[1], tasks[2])
				elif actionName == 'run':
					run(tasks)
				elif actionName == 'pip':
					pip('install '+tasks)
				elif actionName == 'copy':
					copy(tasks[0], tasks[1])
			if actionName == 'build_py':
				for item in tasks:
					if args['exe'] and (item != args['exe'] and item.lower() != args['exe']):
						continue
					print(f'[{itemName}] Building {itemName}/{item}')
					py            = ''
					outputBin     = ''
					errorExpected = 0
					hiddenimports = ''
					zipExtraFiles = []
					testArg       = '-h'
					if type(tasks[item]) == type([]):
						outputBin      = item
						py             = tasks[item][0]
						errorExpected  = tasks[item][1]
					elif type(tasks[item]) == type({}):
						if 'py' in tasks[item]:
							py             = tasks[item]['py']
						if 'outputBin' in tasks[item]:
							outputBin      = tasks[item]['outputBin']
						else:
							outputBin      = item
						if 'errorExpected' in tasks[item]:
							errorExpected  = tasks[item]['errorExpected']
						if 'hiddenimports' in tasks[item] and tasks[item]['hiddenimports']:
							hiddenimports  = tasks[item]['hiddenimports']
						if 'zipExtraFiles' in tasks[item] and tasks[item]['zipExtraFiles']:
							zipExtraFiles  = tasks[item]['zipExtraFiles']
						if 'testArg' in tasks[item]:
							testArg        = tasks[item]['testArg']
							testArg        = '' if testArg == None else testArg
					else:
						raise f'Unexcepted format. Expected `dict` recv `{type(tasks[item])}` with value: {tasks[item]}'
					if hiddenimports:
						hiddenimports = '--hidden-import '+hiddenimports.replace('  ',' ').replace(' ', ' --hidden-import ')
					Build.python( repo=itemName+'/'+item, py=py, outputBin=outputBin, testArg=testArg, errorExpected=errorExpected, hiddenimports=hiddenimports, zipExtraFiles=zipExtraFiles )
			elif actionName in ['build_csharp','build_cpp','build_rust']:
				for item in tasks:
					print(f'[{itemName}] Building {itemName}/{item}')
					outputBin     = ''
					errorExpected = 0
					zipExtraFiles = []
					testArg       = '-h'
					configuration = 'Release'
					if type(tasks[item]) == type([]):
						outputBin      = tasks[item][0]
						errorExpected  = tasks[item][1]
					elif type(tasks[item]) == type({}):
						if 'outputBin' in tasks[item]:
							outputBin      = tasks[item]['outputBin']
						else:
							outputBin      = item
						if 'errorExpected' in tasks[item]:
							errorExpected  = tasks[item]['errorExpected']
						if 'zipExtraFiles' in tasks[item] and tasks[item]['zipExtraFiles']:
							zipExtraFiles  = tasks[item]['zipExtraFiles']
						if 'configuration' in tasks[item]:
							configuration = tasks[item]['configuration']
						if 'testArg' in tasks[item]:
							testArg        = tasks[item]['testArg']
							testArg        = '' if testArg == None else testArg
					else:
						raise f'Unexcepted format. Expected `dict` recv `{type(tasks[item])}` with value: {tasks[item]}'
					if actionName == 'build_csharp':
						Build.csharp( repo=itemName+'/'+item, outputBin=outputBin, testArg=testArg, errorExpected=errorExpected, zipExtraFiles=zipExtraFiles, configuration=configuration )
					elif actionName == 'build_cpp':
						Build.cpp( repo=itemName+'/'+item, outputBin=outputBin, testArg=testArg, errorExpected=errorExpected, zipExtraFiles=zipExtraFiles )
					elif actionName == 'build_rust':
						Build.rust( repo=itemName+'/'+item, outputBin=outputBin, testArg=testArg, errorExpected=errorExpected, zipExtraFiles=zipExtraFiles )

	if not args['job']:
		log_info('Waiting for thread...')
		FileLock.wait()
	log_info(f'Done {sys.argv[1:]}')
	return 0


def chdir( d ):
	if not IS_APPVEYOR:
		return log_debug(f'Ignored chdir({d}). IS_APPVEYOR=false')
	os.chdir(d)


class Requirement:
	@staticmethod
	def python():
		if os.path.isfile(os.environ['scriptpath']+'/python.installed'):
			return log_debug(f'Ignored Requirement.python(). Already loaded')
		pwdb = os.getcwd()
		log_info('Install requirement: pip & co...')
		pip(['-U','pip','wheel','ldap3','pywin32','pypiwin32','tinyaes','dnspython'])

		log_info('Install requirement: pyinstaller...')
		clone('pyinstaller/pyinstaller',ignore_requirements=True,ignore_pip=True)
		run('git fetch --all --tags --prune')
		run('git checkout v5.13.0 .')
		run('git checkout develop bootloader')
		chdir(os.getcwd()+'/bootloader')
		run('%py64% waf configure distclean all --msvc_targets=x64')
		chdir(os.getcwd()+'/../')
		pip(['.'])
		with open(os.environ['scriptpath']+'/python.installed','w') as fp:
			fp.write('1')
		chdir(pwdb)

	@staticmethod
	def go():
		if os.path.isfile(os.environ['scriptpath']+'/go.installed'):
			return log_debug(f'Ignored Requirement.go(). Already loaded');
		log_info('Install requirement: rsrc...')
		run('go get -v github.com/akavel/rsrc')
		os.environ['rsrc'] = os.environ['GOPATH']+r'\bin\rsrc.exe'
		
	@staticmethod
	def csharp():
		pass
		
	@staticmethod
	def cpp():
		if not IS_APPVEYOR:
			return log_debug(f'Ignored Requirement.cpp(). IS_APPVEYOR=false')
		if 'WindowsSdkDir' in os.environ:
			return log_debug(f'Ignored Requirement.cpp(). Already loaded')
		process = Popen(r'("C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat">nul)&&"'+sys.executable+'" -c "import os; print(repr(os.environ))"', stdout=PIPE, shell=True)
		stdout, _ = process.communicate()
		if process.wait() == 0:
			env = eval(stdout.decode('ascii').strip('environ'))
			for key in env:
				try:
					os.environ[key] = env[key]
				except:
					print(f'{key}={env[key]}')

	@staticmethod
	def rust():
		if os.path.isfile(os.environ['scriptpath']+'/rust.installed'):
			return log_debug(f'Ignored Requirement.rust(). Already loaded')
		log_info('Install requirement: rust,cargo...')
		run('choco install -y rustup.install')
		run('rustup.exe install stable-x86_64-pc-windows-msvc')
		run('rustup.exe target add x86_64-pc-windows-msvc')
		

class Build:
	@staticmethod
	def python( repo:str, py:str, outputBin:str, testArg:str, errorExpected:int, hiddenimports:str='', zipExtraFiles:list=[] ) -> None:
		Requirement.python()
		cmd = ''
		hiddenimports = hiddenimports.strip('\r\n\t ').replace('  ',' ')
		if hiddenimports:
			hiddenimports = hiddenimports.split(' ')
		else:
			hiddenimports = []
		pyinstallerNameExe = outputBin.replace(".exe","").replace("\\","/").split('/')[-1]
		if 'dist\\' not in outputBin:
			outputBin = 'dist\\'+outputBin
		if '.exe' not in outputBin:
			outputBin += '.exe'
		PYTHONOPTIMIZE_FLAG = [os.environ['PYTHONOPTIMIZE_FLAG']] if 'PYTHONOPTIMIZE_FLAG' in os.environ and os.environ['PYTHONOPTIMIZE_FLAG'] else []
		if os.path.isfile(py):
			if py.endswith('.spec'):
				cmd = ['%py64%'] + PYTHONOPTIMIZE_FLAG + ['-m','PyInstaller',f'{py}.spec']
			else:
				if not py.endswith('.py'):
					py += '.py'
				cmd = ['%py64%'] + PYTHONOPTIMIZE_FLAG + ['-m','PyInstaller','--key=%pykey%',r'--icon=%scriptpath%\pytools.ico','--onefile',py,'--name',pyinstallerNameExe,'--noupx']+hiddenimports
		elif os.path.isfile(f'{py}.spec'):
			cmd = ['%py64%'] + PYTHONOPTIMIZE_FLAG + ['-m','PyInstaller',f'{py}.spec']
		else:
			if not py.endswith('.py'):
				py += '.py'
			cmd = ['%py64%'] + PYTHONOPTIMIZE_FLAG + ['-m','PyInstaller','--key=%pykey%',r'--icon=%scriptpath%\pytools.ico','--onefile',py,'--name',pyinstallerNameExe,'--noupx']+hiddenimports

		Build._build(cmd, repo=repo, outputBin=outputBin, testArg=testArg, errorExpected=errorExpected, zipExtraFiles=zipExtraFiles )

	def csharp( repo:str, outputBin:str, testArg:str, errorExpected:int, zipExtraFiles:list=[], configuration:str='Release' ) -> None:
		Requirement.csharp()
		Build._build(f'msbuild /t:Build /property:Configuration={configuration} /p:Platform="Any CPU"', repo=repo, outputBin=outputBin, testArg=testArg, errorExpected=errorExpected, zipExtraFiles=zipExtraFiles )

	def cpp( repo:str, outputBin:str, testArg:str, errorExpected:int, zipExtraFiles:list=[] ) -> None:
		Requirement.cpp()
		cmd = 'msbuild /property:Configuration=Release'
		if os.path.isfile('Makefile.msvc'):
			cmd = 'nmake -f Makefile.msvc'
		Build._build(cmd, repo=repo, outputBin=outputBin, testArg=testArg, errorExpected=errorExpected, zipExtraFiles=zipExtraFiles )

	def rust( repo:str, outputBin:str, testArg:str, errorExpected:int, zipExtraFiles:list=[] ):
		Requirement.rust()
		Build._build('cargo build --release --target x86_64-pc-windows-msvc -j %NUMBER_OF_PROCESSORS%', repo=repo, outputBin=outputBin, testArg=testArg, errorExpected=errorExpected, zipExtraFiles=zipExtraFiles )

	def _build( cmd:list, repo:str, outputBin:str, testArg:str, errorExpected:int, zipExtraFiles:list=[], retry:bool=True, lockThread:bool=True ) -> None:
		if '.exe' not in outputBin:
			outputBin += '.exe'

		logFile = os.environ['scriptpath']+'/bin/'+outputBin.replace('\\','/').split('/')[-1].replace('.exe','.log')
		if not args['job']:
			log_info(f'Running thread for {repo}...')
			logOutput = open(logFile,'w')
			Popen([sys.executable, os.path.abspath(__file__),'-j',repo], shell=True, stdout=logOutput, stderr=logOutput, stdin=sys.stdin, env=os.environ)
			return None
		
		log_info(f'Building {repo} ...')
		if lockThread:
			FileLock.get()
		run(cmd)

		if not os.path.isfile(outputBin):
			logOutput.close()
			appveyor_push(logFile)
			return log_err(f'Build {repo} FAIL: `{outputBin}` not present')

		if (_err:=run((outputBin+' '+str(testArg)).strip('\r\n\t '))) != errorExpected:
			if retry:
				log_warn(f'FAIL to build a valid {repo} (This bin return {_err}, expected {errorExpected}) Retrying...')
				return Build._build(cmd=cmd, repo=repo, outputBin=outputBin, testArg=testArg, errorExpected=errorExpected, retry=False, lockThread=False)
			logOutput.close()
			appveyor_push(logFile)
			return log_err(f'FAIL to build a valid {repo} (This bin return {_err}, expected {errorExpected})...')

		for f in [outputBin]+zipExtraFiles:
			copy(f,r'%scriptpath%\bin\\')

		name = outputBin.replace('\\','/').split('/')[-1].replace('.exe','')
		zip(name, [outputBin]+zipExtraFiles)
		appveyor_push(name)


def init() -> None:
	global init
	if args['job']:
		return None
	os.environ['pyver']				   = r'C:\Python38-x64'
	os.environ['py64']				   = os.environ['pyver'] + r'\python.exe'
	os.environ['pyscript']			   = os.environ['pyver'] + r'\scripts'
	os.environ['PATH']				  += r';%USERPROFILE%\.cargo\bin;C:\Program Files\AppVeyor\BuildAgent'
	os.environ['keylen']			   = '64'
	os.environ['scriptpath']		   = os.path.dirname(os.path.realpath(__file__))
	os.environ['_7Z_OUPUT_']		   = os.environ['scriptpath']+r'\bin'
	os.environ['PYTHONOPTIMIZE']	   = '1'
	os.environ['PYTHONOPTIMIZE_FLAG']  = ''
	os.environ['NODE_OPTIONS']         = '--openssl-legacy-provider'
	#os.environ['PYTHONOPTIMIZE_FLAG'] = '-OO'
	os.environ['CGO_ENABLED']		   = '0'
	os.environ['GOPATH']			   = os.environ['scriptpath']+r'\GOPATH'
	os.environ['RUSTFLAGS']			   = '-C target-feature=+crt-static'
	# Generate random key for encryption
	os.environ['pykey']				   = ''.join(random.choices(string.ascii_uppercase + string.digits, k=int(os.environ['keylen'])))
	os.environ['_7Z_PASSWORD_']		   = ''.join(random.choices(string.ascii_uppercase + string.digits, k=int(os.environ['keylen'])))

	log_info('Using 7z key='+os.environ['_7Z_PASSWORD_'])
	print(f'SET "pyver='+os.environ['pyver']+'"')
	print(f'SET "py64='+os.environ['py64']+'"')
	print(f'SET "pyscript='+os.environ['pyscript']+'"')
	print(f'SET "PATH='+os.environ['PATH']+'"')
	print(f'SET "keylen='+os.environ['keylen']+'"')
	print(f'SET "scriptpath='+os.environ['scriptpath']+'"')
	print(f'SET "_7Z_OUPUT_='+os.environ['_7Z_OUPUT_']+'"')
	print(f'SET "PYTHONOPTIMIZE='+os.environ['PYTHONOPTIMIZE']+'"')
	print(f'SET "PYTHONOPTIMIZE_FLAG='+os.environ['PYTHONOPTIMIZE_FLAG']+'"')
	print(f'SET "NODE_OPTIONS='+os.environ['NODE_OPTIONS']+'"')
	print(f'SET "CGO_ENABLED='+os.environ['CGO_ENABLED']+'"')
	print(f'SET "GOPATH='+os.environ['GOPATH']+'"')
	print(f'SET "RUSTFLAGS='+os.environ['RUSTFLAGS']+'"')
	print(f'SET "pykey='+os.environ['pykey']+'"')
	print(f'SET "_7Z_PASSWORD_='+os.environ['_7Z_PASSWORD_']+'"')
	
	run('git config --global user.email "appveyor@appveyor-vm.com"')
	run('git config --global user.name "1mm0rt41PC"')
	run('npm config set audit false --location=global')
	run('npm config set fund false --location=global')
	run(f'appveyor.exe SetVariable -Name _7Z_PASSWORD_ -Value "{os.environ["_7Z_PASSWORD_"]}"')
	os.makedirs(os.environ['scriptpath']+'/bin', exist_ok=True)
	init = lambda: None


def appveyor_push( outputBin:str ) -> None:
	if os.path.isfile(os.environ['_7Z_OUPUT_']+f'\\{outputBin}.7z'):
		run(['appveyor','PushArtifact',f'%_7Z_OUPUT_%\\{outputBin}.7z'])
		return None
	if os.path.isfile(outputBin):
		run(['appveyor','PushArtifact',outputBin])
		return None
	run(['appveyor','PushArtifact',f'%_7Z_OUPUT_%\\{outputBin}.log'])

def zip( outputBin:str, zipExtraFiles:list ) -> None:
	log_info(f'Create {outputBin}.7z with required files...')
	fd, zipName = tempfile.mkstemp()
	zipName += '.lst7z'
	with open(zipName,'w') as fp:
		uniqList = []
		for f in zipExtraFiles:
			f = os.environ['scriptpath']+'\\bin\\'+f.strip('\r\n\t ').split('\\')[-1]
			if f not in uniqList:
				fp.write(f+"\n")
				uniqList.append(f)
	run(f'7z a -t7z -mhe -p%_7Z_PASSWORD_% %_7Z_OUPUT_%\{outputBin}.7z @{zipName}')

def replace( sfile:str, search:str, rpl:str ) -> None:
	log_info(f'Replace string in file `{sfile}`')
	if not IS_APPVEYOR:
		return log_debug(f'replace({sfile},{search},{rpl}) => IS_APPVEYOR=false')
	d = ''
	with open(sfile,'r') as fp:
		d=fp.read().replace(search,rpl)
	with open(sfile,'w') as fp:
		fp.write(d)

def run( cmd:list|str, shell:bool=True, logOutput:str=None ) -> int:
	if logOutput:
		logOutput=Logger(logOutput)
	else:
		logOutput=sys.stdout
	log_debug(f'Running `{cmd}` in dir `{os.getcwd()}`')
	if not IS_APPVEYOR:
		log_debug(f'run({cmd},{shell},{logOutput}) => IS_APPVEYOR=false')
		return 0
	return Popen(cmd, shell=True, stdout=logOutput, stderr=logOutput, stdin=sys.stdin, env=os.environ).wait()

def pip( arg:list|str ):
	if type(arg) == type(''):
		arg = arg.split(' ')
	run(['%py64%', '-m', 'pip', 'install', '--no-warn-script-location'] + arg)

def clone( repo, ignore_requirements=False, ignore_pip=False ):
	if not repo.startswith('https://'):
		repo = 'https://github.com/'+repo
		repoName = repo.replace('/','_').replace(':','_')
	else:
		repoName = repo.split('/')[3].replace('/','_').replace(':','_')
	chdir(os.environ['TMP'])
	run(['git', 'clone', '--depth', '1', repo, repoName])
	chdir(os.environ['TMP']+'/'+repoName)

	if ignore_requirements == False and os.path.isfile('requirements.txt'):
		pip(['-r','requirements.txt'])
	
	if ignore_pip == False and len(glob('*.py')):
		pip(['.'])
		
	if len(glob('*.go')):
		run('go get -v')
	
	if os.path.isfile('packages.config'):
		run('nuget install packages.config -OutputDirectory packages')
		
	for p in glob('*\\packages.config'):
		run(f'nuget install {p} -OutputDirectory packages')

def copy( src:str, dst:str ) -> None:
	log_info(f'Copy file from `{src}` to `{dst}`')
	shutil.copy(os.path.expandvars(src), os.path.expandvars(dst))


def log_err(msg:str) -> None:
	log(msg,'101','Error')
def log_warn(msg:str) -> None:
	log(msg,'101','Warning')
def log_info(msg:str) -> None:
	log(msg,'105','Information')
def log_debug(msg:str) -> None:
	log(msg,'105','Debug')
def log( msg:str, color:str, cat:str ) -> None:
	d = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
	msg = f'[{d}][{cat}] {msg}'
	print(f'\033[{color};93m{msg}\033[0m')
	if IS_APPVEYOR and cat != 'Debug':
		run(['appveyor','AddMessage',msg,'-Category',cat])


class FileLock:
	_fp     = None
	_basefile = os.environ['TMP']+'/thread-lock-'
	_nbWorker = int(os.environ['NUMBER_OF_PROCESSORS'])
	
	# Windows file locking
	@staticmethod
	def lock(f):
		msvcrt.locking(f.fileno(), msvcrt.LK_RLCK, 1)
		FileLock._fp = f

	@staticmethod
	def unlock(f):
		msvcrt.locking(f.fileno(), msvcrt.LK_UNLCK, 1)
	
	@staticmethod
	def get():
		while 1:
			for i in range(1,__class__._nbWorker+1):
				try:
					__class__.lock(open(__class__._basefile+str(i),'w'))
					log_info(f'Thread {i} is aquired')
					return True
				except:
					pass
			sleep(1)
	
	@staticmethod
	def _waitOnce():
		i = 1;
		while i <= __class__._nbWorker:
			isLocked = True
			log_debug(f'Check Thread {i} ?is? free ?')
			while isLocked:
				try:
					os.remove(__class__._basefile+str(i))
					isLocked = False
					log_debug(f'Thread {i} is free !')
					i += 1
				except PermissionError:
					log_debug(f'Thread {i} is busy !?')
					isLocked = True
					i = 1
					sleep(1)
				except Exception:
					log_debug(f'Thread {i} is free ! exception err')
					isLocked = False
					i += 1

	@staticmethod
	def wait():
		log_debug(f'Wait all thread ?')
		sleep(2)
		__class__._waitOnce()
		sleep(2)
		__class__._waitOnce()






if __name__ == '__main__':
	exit(main())
