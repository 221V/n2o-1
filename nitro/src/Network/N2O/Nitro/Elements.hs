{-# LANGUAGE OverloadedStrings, CPP #-}
module Network.N2O.Nitro.Elements where

import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import qualified Data.Text.Lazy as TL
import qualified Data.Text.Lazy.Encoding as TL
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as BL
import qualified Data.ByteString.Char8 as C8
import qualified Data.ByteString.Lazy.Char8 as CL8
import qualified Network.N2O.Nitro as Nitro
import Prelude hiding (id,max,min)

#define ELEMENT_BASE()\
     id          :: BS.ByteString\
   , validation  :: BS.ByteString,             validate    :: BS.ByteString\
   , class_      :: [BS.ByteString],           style       :: BS.ByteString\
   , source      :: [BS.ByteString],           onClick     :: BS.ByteString\
   , onMouseOver :: BS.ByteString,             onKeyPress  :: BS.ByteString\
   , onBlur      :: BS.ByteString,             onChange    :: BS.ByteString\
   , onKeyUp     :: BS.ByteString,             onKeyDown   :: BS.ByteString\
   , onFocus     :: BS.ByteString,             dataFields  :: [(BS.ByteString, BS.ByteString)]\
   , body        :: [Element a],               role        :: BS.ByteString\
   , tabIndex    :: Integer,                   htmlTag     :: BS.ByteString\
   , title       :: T.Text,                    postback    :: Maybe a

#define ELEMENT_BASE_DEFAULTS()\
   id="",class_=[],style="",postback=Nothing,body=[],dataFields=[]\
  ,onFocus="",onBlur="",onChange="",onClick="",onKeyDown="",onKeyUp="",onKeyPress="",onMouseOver=""\
  ,tabIndex=0,validation="",validate="",source=[],role="",title="",htmlTag=undefined

#define CONTROL_BASE()\
  ELEMENT_BASE()

data Element a =
   MkBase
 { ELEMENT_BASE() }
 | MkLiter
 { ELEMENT_BASE(), htmlEncode::Bool, text::TL.Text }
 | MkList
 { ELEMENT_BASE(), ordered::Bool }
 | MkDropDown
 { ELEMENT_BASE(), options::[Element a], value::BS.ByteString, multiple::Bool, disabled::Bool, name::BS.ByteString}
 | MkSpinner
 { ELEMENT_BASE(), image::BS.ByteString }
 | MkMetaLink
 { ELEMENT_BASE(), href::BS.ByteString, hreflang::BS.ByteString, media::BS.ByteString
 , rel::BS.ByteString, sizes::BS.ByteString, type_::BS.ByteString }
 | MkMeta
 { ELEMENT_BASE(), charset::BS.ByteString, content::BS.ByteString, httpEquiv::BS.ByteString, name::BS.ByteString
 , type_::BS.ByteString }
 | MkStyle
 { ELEMENT_BASE(), media::BS.ByteString, scoped::BS.ByteString, type_::BS.ByteString }
 | MkEdit
 { ELEMENT_BASE(), cite::BS.ByteString, datetime::BS.ByteString }
 | MkArea
 { ELEMENT_BASE(), alt::T.Text, coords::BS.ByteString, href::BS.ByteString, hreflang::BS.ByteString
 , media::BS.ByteString, target::BS.ByteString, rel::BS.ByteString, shape::BS.ByteString, type_::BS.ByteString}
 | MkAudio
 { ELEMENT_BASE(), autoplay::Bool, controls::BS.ByteString, loop::BS.ByteString, mediagroup::BS.ByteString
 , muted::BS.ByteString, preload::BS.ByteString, src::BS.ByteString, width::BS.ByteString }
 | MkCanvas
 { ELEMENT_BASE(), height::BS.ByteString, width::BS.ByteString }
 | MkEmbed
 { ELEMENT_BASE(), height::BS.ByteString, width::BS.ByteString, src::BS.ByteString, type_::BS.ByteString }
 | MkIframe
 { ELEMENT_BASE(), height::BS.ByteString, width::BS.ByteString, name::BS.ByteString, sandbox::BS.ByteString
 , seamless::BS.ByteString, src::BS.ByteString, srcdoc::BS.ByteString }
 | MkImage
 { ELEMENT_BASE(), alt::T.Text, height::BS.ByteString, ismap::BS.ByteString, src::BS.ByteString, usemap::Bool
 , width::BS.ByteString, image::BS.ByteString }
 | MkMap
 { ELEMENT_BASE(), name::BS.ByteString }
 | MkObject
 { ELEMENT_BASE(), data_::BS.ByteString, form::BS.ByteString, height::BS.ByteString, name::BS.ByteString
 , type_::BS.ByteString, usemap::Bool, width::BS.ByteString }
 | MkParam
 { ELEMENT_BASE(), name::BS.ByteString, value::BS.ByteString }
 | MkSource
 { ELEMENT_BASE(), media::BS.ByteString, src::BS.ByteString, type_::BS.ByteString }
 | MkTrack
 { ELEMENT_BASE(), default_::BS.ByteString, kind::BS.ByteString, label::BS.ByteString, src::BS.ByteString
 , srclang::BS.ByteString }
 | MkVideo
 { ELEMENT_BASE(), autoplay::Bool, controls::BS.ByteString, height::BS.ByteString, loop::BS.ByteString
 , width::BS.ByteString, mediagroup::BS.ByteString, muted::BS.ByteString, poster::BS.ByteString
 , preload::BS.ByteString, src::BS.ByteString}
 | MkButton
 { ELEMENT_BASE(), autofocus::Bool, disabled::Bool, form::BS.ByteString, formaction::BS.ByteString
 , formenctype::BS.ByteString, formmethod::BS.ByteString, formtarget::BS.ByteString, formnovalidate::Bool
 , name::BS.ByteString, type_::BS.ByteString, value::BS.ByteString }
 | MkFielset
 { ELEMENT_BASE(), disabled::Bool, form::BS.ByteString, name::BS.ByteString, legend::BS.ByteString }
 | MkForm
 { ELEMENT_BASE(), accept_charset::BS.ByteString, action::BS.ByteString, autocomplete::Bool, enctype::BS.ByteString
 , method::BS.ByteString, name::BS.ByteString, novalidate::Bool, target::BS.ByteString }
 | MkKeygen
 { ELEMENT_BASE(), autofocus::Bool, challenge::BS.ByteString, disabled::Bool, form::BS.ByteString
 , keytype::BS.ByteString, name::BS.ByteString }
 | MkLabel
 { ELEMENT_BASE(), for::BS.ByteString, form::BS.ByteString }
 | MkMeter
 { ELEMENT_BASE(), high::BS.ByteString, low::BS.ByteString, max::BS.ByteString, min::BS.ByteString
 , optimum::BS.ByteString, value::BS.ByteString }
 | MkOptgroup
 { ELEMENT_BASE(), disabled::Bool, label::BS.ByteString }
 | MkOption
 { ELEMENT_BASE(), disabled::Bool, label::BS.ByteString, selected::Bool, value::BS.ByteString }
 | MkOutput
 { ELEMENT_BASE(), for::BS.ByteString, form::BS.ByteString, name::BS.ByteString }
 | MkProgress
 { ELEMENT_BASE(), max::BS.ByteString, value::BS.ByteString }
 | MkSelect
 { ELEMENT_BASE(), autofocus::Bool, disabled::Bool, form::BS.ByteString, multiple::Bool, name::BS.ByteString
 , required::Bool, size::BS.ByteString}
 | MkTextarea
 { ELEMENT_BASE(), autofocus::Bool, cols::BS.ByteString, dirname::BS.ByteString, disabled::Bool, form::BS.ByteString
 , maxlength::BS.ByteString, name::BS.ByteString, placeholder::BS.ByteString, readonly::Bool, required::Bool
 , rows::BS.ByteString, wrap::BS.ByteString, value::BS.ByteString }
 deriving (Show)

base :: Element a
base = MkBase{ELEMENT_BASE_DEFAULTS()}

literal :: Element a
literal = MkLiter{ELEMENT_BASE_DEFAULTS(),htmlEncode=True,text=""}

panel :: Element a
panel = base{htmlTag="div"}

list :: Element a
list = MkList{ELEMENT_BASE_DEFAULTS(),ordered=False}

dropDown :: Element a
dropDown = MkDropDown{ELEMENT_BASE_DEFAULTS(),options=[],value="",multiple=False,disabled=False,name=""}

radioGroup :: Element a
radioGroup = base

spinner :: Element a
spinner = MkSpinner{ELEMENT_BASE_DEFAULTS(),image="/priv/static/spinner.gif"}

head :: Element a
head = base

metaLink :: Element a
metaLink = MkMetaLink{ELEMENT_BASE_DEFAULTS(),href="",hreflang="",media="",rel="",sizes="",type_=""}

style_ :: Element a
style_ = MkStyle{ELEMENT_BASE_DEFAULTS(),media="",scoped="",type_=""}

title_ :: Element a
title_ = base

del :: Element a
del = MkEdit{ELEMENT_BASE_DEFAULTS(),cite="",datetime=""}

ins :: Element a
ins = del

area :: Element a
area = MkArea{ELEMENT_BASE_DEFAULTS(),alt="",coords="",href="",hreflang="",media="",target="",rel="",shape="",type_=""}

audio :: Element a
audio = MkAudio{ELEMENT_BASE_DEFAULTS(),autoplay=True,controls="",loop="",mediagroup="",muted="",preload="",src="",width=""}

canvas :: Element a
canvas = MkCanvas{ELEMENT_BASE_DEFAULTS(),height="",width=""}

embed :: Element a
embed = MkEmbed{ELEMENT_BASE_DEFAULTS(),height="",width="",src="",type_=""}

iframe :: Element a
iframe = MkIframe{ELEMENT_BASE_DEFAULTS(),height="",width="",src="",srcdoc="",name="",sandbox="",seamless=""}

image_ :: Element a
image_ = MkImage{ELEMENT_BASE_DEFAULTS(),alt="",height="",ismap="",src="",usemap=False,width="",image=""}

map_ :: Element a
map_ = MkMap{ELEMENT_BASE_DEFAULTS(),name=""}

object_ :: Element a
object_ = MkObject{ELEMENT_BASE_DEFAULTS(),data_="",form="",height="",name="",type_="",usemap=False,width=""}

param :: Element a
param = MkParam{ELEMENT_BASE_DEFAULTS(),value="",name=""}

source_ :: Element a
source_ = MkSource{ELEMENT_BASE_DEFAULTS(),media="",src="",type_=""}

track :: Element a
track = MkTrack{ELEMENT_BASE_DEFAULTS(),default_="",kind="",src="",srclang="",label=""}

video :: Element a
video = MkVideo{ELEMENT_BASE_DEFAULTS(),autoplay=False,controls="",height="",loop="",mediagroup="",muted=""
               ,poster="",preload="",src="",width=""}

button:: Element a
button = MkButton{ELEMENT_BASE_DEFAULTS(),autofocus=True,disabled=False,form="",formaction="",formmethod=""
                 ,formtarget="",formnovalidate=False,formenctype="",name="",type_="button",value=""}

datalist :: Element a
datalist = base

fieldset :: Element a
fieldset = MkFielset{ELEMENT_BASE_DEFAULTS(),disabled=False,form="",name="",legend=""}

form_ :: Element a
form_ = MkForm{ELEMENT_BASE_DEFAULTS(),accept_charset="",action="",autocomplete=False,enctype="",method="",name=""
             ,novalidate=False,target=""}

keygen :: Element a
keygen = MkKeygen{ELEMENT_BASE_DEFAULTS(),autofocus=True,challenge="",disabled=False,form="",keytype="",name=""}

legend_ :: Element a
legend_ = base

label_ :: Element a
label_ = MkLabel{ELEMENT_BASE_DEFAULTS(),for="",form=""}

meter :: Element a
meter = MkMeter{ELEMENT_BASE_DEFAULTS(),high="",low="",max="",min="",optimum="",value=""}

optgroup :: Element a
optgroup = MkOptgroup{ELEMENT_BASE_DEFAULTS(),disabled=False,label=""}

option :: Element a
option = MkOption{ELEMENT_BASE_DEFAULTS(),disabled=False,label="",selected=False,value=""}

output :: Element a
output = MkOutput{ELEMENT_BASE_DEFAULTS(),for="",form="",name=""}

progress :: Element a
progress = MkProgress{ELEMENT_BASE_DEFAULTS(),max="",value=""}

select :: Element a
select = MkSelect{ELEMENT_BASE_DEFAULTS(),autofocus=False,disabled=False,form="",multiple=False,name=""
                 ,required=False,size=""}

textarea :: Element a
textarea = MkTextarea{ELEMENT_BASE_DEFAULTS(),autofocus=False,cols="",dirname="",disabled=False,form=""
                     ,maxlength="",name="",placeholder="",readonly=False,required=False,rows="",wrap="",value=""}
