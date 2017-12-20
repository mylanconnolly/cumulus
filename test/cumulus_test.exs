defmodule CumulusTest do
  use ExUnit.Case

  doctest Cumulus

  describe "Cumulus.object_url/2" do
    test "it returns a properly-formatted Google Cloud Storage URL" do
      assert Cumulus.object_url("123", "456") == "https://www.googleapis.com/storage/v1/b/123/o/456"
    end
  end

  describe "Cumulus.bucket_upload_url/1" do
    test "it returns a properly-formatted Google Cloud Storage URL" do
      assert Cumulus.bucket_upload_url("123") == "https://www.googleapis.com/upload/storage/v1/b/123/o"
    end
  end

  describe "Cumulus.bucket_url/1" do
    test "it returns a properly-formatted Google Cloud Storage URL" do
      assert Cumulus.bucket_url("123") == "https://www.googleapis.com/storage/v1/b/123"
    end
  end
end
