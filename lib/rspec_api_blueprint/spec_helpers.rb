unless respond_to? :last_request
  def last_request
    @request
  end
end

unless respond_to? :last_response
  def last_response
    @response
  end
end
