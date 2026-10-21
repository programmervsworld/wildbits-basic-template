import re
import sys

defines = {}
line = 1000
for s in sys.stdin:
	s = s.strip()
	if s.startswith("#define"):
		define = re.match(r"^#define\s+(\S+)\s+(.+)$", s)
		if not define:
			continue
		defines[define.group(1)] = define.group(2)
		continue
	for name, value in defines.items():
		s = re.sub(r"(?<![A-Za-z0-9_$]){0}(?![A-Za-z0-9_$])".format(re.escape(name)), value, s)
	print("{0} {1}".format(line,s))
	line += 10
print("{0}{0}{0}{0}".format(chr(255)))
