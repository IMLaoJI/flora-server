{-# LANGUAGE QuasiQuotes #-}

module FloraWeb.Components.Header where

import Control.Monad.Reader
import Data.Text
import Lucid
import Lucid.Alpine
import PyF

import Flora.Environment.Config
import FloraWeb.Components.Navbar (navbar)
import FloraWeb.Components.Utils (property_, text)
import FloraWeb.Templates.Types (FloraHTML, TemplateEnv (..))

header :: FloraHTML
header = do
  TemplateEnv{title} <- ask
  doctype_
  html_
    [ lang_ "en"
    , class_ "no-js"
    , xData_
        "{ theme: \
        \ localStorage.getItem('theme') \
        \   || (window.matchMedia('(prefers-color-scheme: dark)').matches \
        \   ? 'dark' : 'light') \
        \ }"
    , xBind_ "data-theme" "(theme === 'dark') ? 'dark' : ''"
    , xInit_ "$watch('theme', val => localStorage.setItem('theme', val))"
    ]
    $ do
      head_ $ do
        meta_ [charset_ "UTF-8"]
        meta_ [name_ "viewport", content_ "width=device-width, initial-scale=1"]
        title_ (text title)

        script_ [type_ "module"] $ do
          toHtmlRaw @Text
            [str|
          document.documentElement.classList.remove('no-js');
          document.documentElement.classList.add('js');
          |]

        jsLink
        cssLink
        link_
          [ rel_ "search"
          , type_ "application/opensearchdescription+xml"
          , title_ "Search on Flora"
          , href_ "/opensearch.xml"
          ]
        meta_ [name_ "description", content_ "A package repository for the Haskell ecosystem"]
        ogTags
        theme
        link_ [rel_ "icon", href_ "/static/favicon.svg", type_ "image/svg+xml"]
        -- link_ [rel_ "canonical", href_ $ getCanonicalURL assigns]
        meta_ [name_ "twitter:dnt", content_ "on"]

      body_ [] $ do
        navbar

jsLink :: FloraHTML
jsLink = do
  TemplateEnv{assets, environment} <- ask
  let jsURL = "/static/" <> assets.jsBundle.name
  case environment of
    Production ->
      script_ [src_ jsURL, type_ "module", defer_ "", integrity_ ("sha256-" <> assets.jsBundle.hash)] ("" :: Text)
    _ ->
      script_ [src_ jsURL, type_ "module", defer_ ""] ("" :: Text)

cssLink :: FloraHTML
cssLink = do
  TemplateEnv{assets, environment} <- ask
  let cssURL = "/static/" <> assets.cssBundle.name
  case environment of
    Production ->
      link_ [rel_ "stylesheet", href_ cssURL, integrity_ ("sha256-" <> assets.cssBundle.hash)]
    _ ->
      link_ [rel_ "stylesheet", href_ cssURL]

ogTags :: FloraHTML
ogTags = do
  TemplateEnv{title, description} <- ask
  meta_ [property_ "og:title", content_ title]
  meta_ [property_ "og:site_name", content_ "Flora"]
  meta_ [property_ "og:description", content_ description]
  meta_ [property_ "og:url", content_ ""]
  meta_ [property_ "og:image", content_ ""]
  meta_ [property_ "og:image:width", content_ "160"]
  meta_ [property_ "og:image:height", content_ "160"]
  meta_ [property_ "og:locale", content_ "en_GB"]
  meta_ [property_ "og:type", content_ "website"]

theme :: FloraHTML
theme = do
  meta_ [name_ "theme-color", content_ "#000", media_ "(prefers-color-scheme: dark)"]
  meta_ [name_ "theme-color", content_ "#FFF", media_ "(prefers-color-scheme: light)"]
