require 'test_helper'
#require 'test/unit'

class GitosisAdminTest < Test::Unit::TestCase

  def test_init
    mg = mock_git
    @git = GitosisAdmin.new
  end

  def test_push_config
    mg = mock_git
    mg.expects(:pull)
    mg.expects(:add)
    mg.expects(:commit).with('message')
    mg.expects(:push)

    @git = GitosisAdmin.new
    @git.push_config('message')
  end

  def test_push_key
    mg = mock_git
    mg.expects(:pull)
    mg.expects(:add).twice()
    mg.expects(:commit).with('message')
    mg.expects(:push)

    @git = GitosisAdmin.new
    @git.push_key('key', 'message')
  end

  def test_remove_key
    mg = mock_git
    mg.expects(:pull)
    mg.expects(:remove)
    mg.expects(:add)
    mg.expects(:commit).with('message')
    mg.expects(:push)

    @git = GitosisAdmin.new
    @git.remove_key('key', 'message')
  end
 
end