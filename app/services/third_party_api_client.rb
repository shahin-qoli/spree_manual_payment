class ThirdPartyApiClient
  class Response
    attr_reader :document_id, :error_message

    def initialize(success:, document_id: nil, error_message: nil)
      @success = success
      @document_id = document_id
      @error_message = error_message
    end

    def success?
      @success
    end
  end

  def initialize(base_url:, api_key:)
    @base_url = base_url
    @api_key = api_key
  end

  def create_document(account_code:, amount:, reference_number:, order_number:, payment_date:)
    response = make_request(
      method: :post,
      endpoint: '/documents',
      body: {
        account_code: account_code,
        amount: amount,
        reference_number: reference_number,
        order_number: order_number,
        payment_date: payment_date.iso8601
      }
    )

    if response.success?
      Response.new(
        success: true,
        document_id: response.body['document_id']
      )
    else
      Response.new(
        success: false,
        error_message: response.body['error'] || 'Unknown error'
      )
    end
  end

  private

  def make_request(method:, endpoint:, body: nil)
    uri = URI.join(@base_url, endpoint)
    
    request = case method
    when :get
      Net::HTTP::Get.new(uri)
    when :post
      Net::HTTP::Post.new(uri)
    when :put
      Net::HTTP::Put.new(uri)
    when :delete
      Net::HTTP::Delete.new(uri)
    end

    request['Authorization'] = "Bearer #{@api_key}"
    request['Content-Type'] = 'application/json'
    request.body = body.to_json if body

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    
    http.request(request)
  end
end 