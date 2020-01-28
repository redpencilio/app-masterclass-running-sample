defmodule Dispatcher do
  use Matcher
  define_accept_types [
    json: [ "application/json", "application/vnd.api+json" ]
  ]

  match "/books/*path", _ do
    forward conn, path, "http://books-service/books/"
  end

  match "/authors/*path", _ do
    forward conn, path, "http://books-service/authors/"
  end

  match "/sessions/*path", %{ accept: %{ json: true } } do
    forward conn, path, "http://mock-login/sessions/"
  end

  last_match
end