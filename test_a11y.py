import sys
html_content = open("skills/geofeed-tuner/scripts/templates/index.html").read()

if '<span class="close" tabindex="0">' in html_content:
    print("Found modal close")
if '<select id="filterStatus"' in html_content:
    print("Found filterStatus")
if '<input type="text" id="filterIpPrefix"' in html_content:
    print("Found filterIpPrefix")
