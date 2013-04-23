var fork = require('child_process').fork;,
    cwd = path.join(__dirname, '..'),
    stdio = 'inherit';

fork('coffee', ['-cmo', 'lib', 'src'], {cwd: cwd, stdio: stdio});