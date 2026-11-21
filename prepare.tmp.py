import json
from pathlib import Path
from PIL import Image,ImageDraw
from collections import Counter
frames=json.loads(Path('design_layers.tmp.json').read_text(encoding='utf8'))
result={}
for f in frames:
 path=Path('docs/screenshots')/(f['id']+'.webp')
 im=Image.open(path).convert('RGB'); sw,sh=im.size
 if (sw,sh)!=(f['w'],f['h']): im=im.resize((f['w'],f['h']))
 nodes=[]
 for n in f['nodes']:
  t=n['t'].strip(); x,y,w,h=[n[k] for k in ('x','y','w','h')]
  if x>=375 or y>=f['h'] or x+w<0 or y+h<0:continue
  if not t and w!=0:continue
  a,b=max(0,x),max(0,y);c,d=min(x+w,375),min(y+h,f['h'])
  foreground=n['color']; draw=False
  if t and t!='9:41' and foreground and c>a+2 and d>b+2 and x>=0 and y>=0 and x+w<=375 and y+h<=f['h']:
   border=[im.getpixel((j,k)) for j in range(a,c,2) for k in (b,d-1)]+[im.getpixel((j,k)) for k in range(b,d,2) for j in (a,c-1)]
   bg,count=Counter(border).most_common(1)[0]
   similar=sum(max(abs(v-z) for v,z in zip(p,bg))<12 for p in border)
   # Only lift text from a flat paint surface. Keep type over photos and mixed rich text in the artwork.
   ink=any(max(abs(v-z) for v,z in zip(pixel,foreground))<24 for pixel in im.crop((a,b,c,d)).getdata())
   if ink and similar>=len(border)*0.94 and max(abs(v-z) for v,z in zip(bg,foreground))>35:
    ImageDraw.Draw(im).rectangle((a,b,c-1,d-1),bg);draw=True
  v={'t':t,'x':x,'y':y,'w':w,'h':h}
  if draw:v.update(s=n['size'],c=int.from_bytes(bytes(foreground),'big'),a=n['align'][0],b=n['font'].lower() in ('heavy','semibold','bold','black','medium'))
  nodes.append(v)
 im.save(Path('assets/screens')/path.name,'WEBP',quality=95)
 result[f['id']]={'h':f['h'],'nodes':nodes}
Path('assets/layout.json').write_text(json.dumps(result,ensure_ascii=False,separators=(',',':')),encoding='utf8')
