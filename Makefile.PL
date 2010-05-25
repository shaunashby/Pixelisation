use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Pixelisation',
    AUTHOR              => 'Shaun Ashby <shaun.ashby@unige.ch>',
    VERSION_FROM        => 'lib/Pixelisation.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'  => 0.94,
	'File::Copy'  => 2.0,
	'Path::Class::File' => 0,
	'File::ChangeNotify::Event' => 0,
	'namespace::clean'  => 0.11,
	'Moose'       => 0.93,
	'Moose::Role' => 0.93,
	'Moose::Util::TypeConstraints' => 0.93,
	'MooseX::Role::Cmd' => 0.09,
	'IPC::Cmd'    => 0.4,
	'IPC::Run'    => 0.89
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Pixelisation-*' },
);

sub MY::postamble {
    return <<'MAKE_FRAG';
REV:=9999
INST:=isgri
BASE_DATA_DIR:=/unsaved_data/$(USER)/tmp/data
TEST_DATA:=t/data/pixels.tgz
UUID:=$(shell uuidgen | sed -e 's/-//g')
EXPORT_TRIGGER_DIR:=pix/job/input/triggers
TRIGGER_HOST:=isdclogin2

install_config: lib/Pixelisation/Config.pm
	@echo ">> Creating Pixelisation::Config"

lib/Pixelisation/Config.pm: lib/Pixelisation/Config.pm.in
	@cat $^ | sed -e "s#@PIX_HOME@#$(PWD)#g" > $@

install_test_data: export_trigger_dir
	@echo ">> Running test data target. Installing data on $(TRIGGER_HOST)...."
	@ssh $(TRIGGER_HOST) "mkdir -p $(BASE_DATA_DIR)/$(UUID)"
	@cat $(TEST_DATA) | ssh $(TRIGGER_HOST) tar -xzf - -C $(BASE_DATA_DIR)/$(UUID)

export_trigger_dir:
	@if [ ! -d $(EXPORT_TRIGGER_DIR) ]; then \
	 echo ">> Creating trigger directory: $(EXPORT_TRIGGER_DIR)"; \
	 mkdir -p $(EXPORT_TRIGGER_DIR) > /dev/null 2>&1; \
	fi

test_export_trigger: install_test_data
	@echo ">> Generating test trigger for $(UUID)"
	$(NOECHO) $(TOUCH) $(EXPORT_TRIGGER_DIR)/$(UUID).trigger
	@echo "$(REV) $(INST) $(TRIGGER_HOST):$(BASE_DATA_DIR)/$(UUID)" >> $(EXPORT_TRIGGER_DIR)/$(UUID).trigger

clean_testdata:
	@echo ">> Cleaning test area $(BASE_DATA_DIR)"
	@rm -rf $(BASE_DATA_DIR)

MAKE_FRAG
    }
