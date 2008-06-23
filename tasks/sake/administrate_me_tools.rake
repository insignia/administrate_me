# for the correct use of this sake tasks, you'll need to have installed the
# following dependencies:
#   - git
#   - sake
namespace :ame do
  namespace :install do
    #usage: sake ame:install:latest
    desc "install the lastest administrate_me plugin version from github repository"
    task :latest do
      puts   "downloading lastest version..."
      system "git clone git://github.com/jmax/administrate_me.git vendor/plugins/administrate_me"
      system "rm -rf vendor/plugins/administrate_me/.git"
      puts   "done!"
    end
  end

  # IMPORTANT: it will be very wisely that you don't have pending commits
  # before this tasks execution.
  namespace :svn do
    #usage: sake ame:svn:upgrade
    desc "upgrade administrate_me version from a svn repo."
    task :upgrade do
      puts   "removing latest version..."
      system "svn remove vendor/plugins/administrate_me"
      system "svn commit -m 'Remove old administrate_me version'"
      system "sake ame:install:latest"
      puts   "adding new version to repo..."
      system "svn add vendor/plugins/administrate_me"
      system "svn commit -m 'Install latest administrate_me version'"
    end
  end

  namespace :git do
    #usage: sake ame:git:upgrade
    desc "upgrade administrate_me version from a git repo."
    task :upgrade do
      puts   "removing latest version..."
      system "git rm -r vendor/plugins/administrate_me"
      system "git commit -m 'Remove old administrate_me version'"
      system "sake ame:install:latest"
      puts   "adding new version to repo..."
      system "git add vendor/plugins/administrate_me"
      system "git commit -m 'Install latest administrate_me version'"
    end
  end
end