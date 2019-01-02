internetRequest = component.proxy(component.list("internet")()).request
function parseXml(xml)
  local function a(b)local c={}string.gsub(b,"([%-%w]+)=([\"'])(.-)%2",function(d,e,f)c[d]=f end)return c end;local function g(b)local h={}local i={}table.insert(h,i)local j,k,l,m,n;local o,p=1,1;while true do j,p,k,l,m,n=string.find(b,"<(%/?)([%w:]+)(.-)(%/?)>",o)if not j then break end;local q=string.sub(b,o,j-1)if not string.find(q,"^%s*$")then table.insert(i,q)end;if n=="/"then table.insert(i,{label=l,xarg=a(m),empty=1})elseif k==""then i={label=l,xarg=a(m)}table.insert(h,i)else local r=table.remove(h)i=h[#h]if#h<1 then error("nothing to close with "..l)end;if r.label~=l then error("trying to close "..r.label.." with "..l)end;table.insert(i,r)end;o=p+1 end;local q=string.sub(b,o)if not string.find(q,"^%s*$")then table.insert(h[#h],q)end;if#h>1 then error("unclosed "..h[#h].label)end;return h[1]end;return g(xml)
end

themes = {
  {"Авто","auto"},
  {"Армия и оружие","army"},
  {"Наука","science"},
  {"Игры", "games"}
}

function parseYandexNews(xml)
  local oldResult,result = parseXml(xml),{}
  
  for i = 6,#oldResult[2][1] do
    result[i-5] = {}
    result[i-5]["title"] = oldResult[2][1][i][1][1]
    result[i-5]["description"] = oldResult[2][1][i][4][1]
  end  
  return result
end

function loadYandexNews(theme)
  local info = ""
  local content = internetRequest("https://news.yandex.ru/" .. theme .. ".rss")
  while true do
    local read = content.read()
    if(read == nil) then break end
    info = info .. read
  end
  return parseYandexNews(info)
end