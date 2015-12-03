var gulp = require('gulp');
var gutil = require('gulp-util');
var coffee = require('gulp-coffee');
var watch = require('gulp-watch');

gulp.task('coffee', function() {
  gulp.src('./src/*.coffee')
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('./build/'));
});

gulp.task('default', ['coffee']);

gulp.task('watch', function () {
  gulp.watch('./src/**/*.coffee', ['coffee']);
});
