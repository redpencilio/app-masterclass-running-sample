defmodule Dispatcher do
  use Matcher
  define_accept_types []

  match "/books/*path", _ do
    forward conn, path, "http://books-service/books/"
  end

  match "/authors/*path", _ do
    forward conn, path, "http://books-service/authors/"
  end

  last_match
end