class FakeS3
  def get_object(bucket:, key:, response_target:)
    File.open(response_target, 'wb') do |file|
      file.write(objects[bucket][key])
    end
  end

  def put_object(bucket:, key:, body:)
    objects[bucket][key] = body
  end

  # @api private
  def objects
    @objects ||= Hash.new { |hash, key| hash[key] = {} }
  end
end
