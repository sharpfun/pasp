import sys

for line in sys.stdin:
  if " :durative-actions" in line:
    line = line.replace(" :durative-actions", "")
  if "(:durative-action" in line:
    line = line.replace("(:durative-action", "(:action")
  if ":condition" in line:
    line = line.replace(":condition", ":precondition")
  if ":duration (= ?duration 0)" in line:
    continue
  for phrase in ["(at start ", "(at end "]:
    while phrase in line:
      brackets_counter = 1
      for i in range(line.index(phrase)+1, len(line)):
        if line[i]=="(":
          brackets_counter+=1
        if line[i]==")":
          brackets_counter-=1
        if brackets_counter == 0:
          line = line[:i] + line[i+1:]
          line = line.replace(phrase, "", 1)
          break
  sys.stdout.write(line)
