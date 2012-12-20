module Metaforce
  class Job::Deploy < Job

    def initialize(client, path, options={})
      super(client)
      @path, @options = path, options
    end

    # Public: Deploy to Salesforce.
    def perform
      @id = client._deploy(payload, @options).id
      super
    end

    # Public: Returns the DeployResult or RetrieveResult
    def result
      client.status(id, :deploy)
    end

    # Public: Returns true if the deploy was successful.
    def success?
      result.success
    end

    # Public: Base64 encodes the contents of the zip file.
    def payload
      Base64.encode64(File.open(file, 'rb').read)
    end

  private

    def file
      File.file?(@path) ? @path : zip_file
    end

    def zip_file
      path = Dir.mktmpdir
      File.join(path, 'deploy.zip').tap do |path|
        Zip::ZipFile.open(path, Zip::ZipFile::CREATE) do |zip|
          Dir["#{@path}/**/**"].each do |file|
            zip.add(file.sub("#{File.dirname(@path)}/", ''), file)
          end
        end
      end
    end

  end
end
