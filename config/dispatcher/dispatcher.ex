defmodule Dispatcher do
  use Matcher
  define_accept_types [
    json: [ "application/json", "application/vnd.api+json" ]
  ]

  match "/books/*path", _ do
    forward conn, path, "http://resource/books/"
  end

  match "/authors/*path", _ do
    forward conn, path, "http://resource/authors/"
  end

  match "/offers/*path", _ do
    forward conn, path, "http://resource/offers/"
  end

  match "/projects/*path", _ do
    forward conn, path, "http://resource/projects/"
  end

  match "/sessions/*path", %{ accept: %{ json: true } } do
    forward conn, path, "http://mock-login/sessions/"
  end

  last_match
end
