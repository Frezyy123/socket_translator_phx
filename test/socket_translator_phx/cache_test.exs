defmodule SocketTranslatorPhx.CacheTest do
  use ExUnit.Case
  alias SocketTranslatorPhx.Workers.CacheWorker

  describe "Cache tests" do
    setup do
      on_exit(fn -> CacheWorker.clear_cache() end)
    end

    test "Put string into cache, then get it" do
      CacheWorker.put_message_to_cache("Message_for_cache", "Сообщенька для кеша")

      assert "Message_for_cache" == CacheWorker.get_translated_message_from_cache("Сообщенька для кеша")
      assert nil == CacheWorker.get_translated_message_from_cache("Сообщенька мимо проходила")
      :timer.sleep(3100)
      assert nil == CacheWorker.get_translated_message_from_cache("Сообщенька для кеша")
    end

    test "Wait 2 seconds, check cache, then wait 1 second. Message should be empty." do
      CacheWorker.put_message_to_cache("Message_for_cache", "Сообщенька для кеша")
      :timer.sleep(2100)

      assert "Message_for_cache" == CacheWorker.get_translated_message_from_cache("Сообщенька для кеша")

      :timer.sleep(1100)
      assert nil == CacheWorker.get_translated_message_from_cache("Сообщенька для кеша")
    end
  end
end
